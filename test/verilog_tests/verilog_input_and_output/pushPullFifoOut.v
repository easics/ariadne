// This file is part of ariadne.
//
// ariadne is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// ariadne is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// ariadne. If not, see <https://www.gnu.org/licenses/>.


`resetall
`timescale 1ns/1ps

module pushPullFifoOut
 #(parameter  dataWidth       = 8*16,
              extraFifoDepth  = 0,           // Beyond what's needed for basic operation
                                             // For example, if retiming registers are needed
                                             // between this module and the sink module, then
                                             // this number must be increased by the number of
                                             // registers in the round-trip path.
                                             // This can also be used if you simply want a deeper
                                             // fifo.
              numInterfaces   = 1,           // Some blocks drive more than 1 data sink
              noInputRegs     = 0            // If this is set to 1, then input registers in the data
                                             // and handshake paths won't be instantiated.
  )
  (
    // System inputs
  input                                      mclk,
  input                                      readRun_r,
  input        [numInterfaces-1:0]           enable_r,
  input                                      clearErrors_r,

    // Interface from the parent module
  input                                      dataValidFromParent,
  input        [dataWidth-1:0]               dataFromParent,

    // Defined interface pins - tie directly to the parent module inputs
  input        [numInterfaces-1:0]           reqFromNext,

    // Interface to the parent module
  output                                      dataXferToParent,
  output                                      readyToParent,

    // Defined interface pins - tie directly to the parent module outputs
  output  reg  [numInterfaces-1:0]            xferToNext,
  output  reg  [numInterfaces*dataWidth-1:0]  dataToNext,
  output  reg  [numInterfaces-1:0]            counterError
  );

  `include "log2.vi"

  localparam fifoDepth = (noInputRegs == 1) ? extraFifoDepth + 2 : extraFifoDepth + 4;
  localparam countBits = log2(fifoDepth);

  reg   [numInterfaces-1:0]  reqFromNext_r;
  wire  [numInterfaces-1:0]  fifoCountFull;
  wire  [numInterfaces-1:0]  fifoCountEmpty;

    // Data can be transferred if there is room in the fifo and if data is available from the parent and if
    // the module is active.  There's room in the fifo if either the fifo has been popped or if the word
    // count indicates the fifo isn't full.  The count is pessimistic, since it increments immediately, but
    // decrements with delay (two registers between the popfifo signal in the downstream block and reqFromNext_r).
  assign readyToParent  = &(reqFromNext_r | ~fifoCountFull) & readRun_r;
  assign dataXferToParent = readyToParent & dataValidFromParent;

  // create an interface and counter for each interface instance.  The counter will keep a pessimistic count 
  // of the number of words in the downstream fifo for this interface.
generate
  genvar i;
    
    for (i = 0; i < numInterfaces; i = i + 1)
     begin: genCounters

      reg  [countBits-1:0]      fifoWordCount;

      assign fifoCountFull[i] = (fifoWordCount == fifoDepth);
      assign fifoCountEmpty[i] = (fifoWordCount == 'h0);

      if (noInputRegs == 1)
       begin: gen_noInputRegs
        always @(*)
         begin
          reqFromNext_r[i]  = enable_r[i] ? reqFromNext[i] : 1'b0;
         end
       end
      else
       begin: gen_inputRegs
        always @(posedge mclk)
         begin
            // Retime the interface input
          reqFromNext_r[i]  <= enable_r[i] ? reqFromNext[i] : 1'b0;
         end
       end

      always @(posedge mclk)
       begin
          // Generate the interface outputs
        xferToNext[i]     <= dataXferToParent & enable_r[i];

        if (dataXferToParent && enable_r[i])
         begin
          dataToNext[i*dataWidth +: dataWidth]     <= dataFromParent;
         end
        `ifdef CLOBBER
        else
         begin
          dataToNext[i*dataWidth +: dataWidth]     <= 'hX;
         end
        `endif

          // There are two counter errors to look at:
          // (1) the counter is at its max value and then there is a dataXferToParent without a reqFromNext_r and
          // (2) the counter is at its min value and then there is a reqFromNext_r.
          // The first is functionally impossible by the definition of dataXferToParent.  Therefore, we only
          // need to look for the second.  readRun_r is included to prevent an error shortly after readRun_r goes
          // low.
        counterError[i]    <= (counterError[i] & ~clearErrors_r) | (fifoCountEmpty[i] & reqFromNext_r[i] & readRun_r);

          // Create the fifo word counter
        case (1'b1)
    
          (!readRun_r || !enable_r[i]): 
            fifoWordCount <= 'h0;
    
          (readRun_r && enable_r[i] &&  reqFromNext_r[i] && !dataXferToParent):  // data taken out, but not put in - subtract 1
            fifoWordCount <= fifoWordCount - 1;
    
          (readRun_r && enable_r[i] && !reqFromNext_r[i] &&  dataXferToParent):  // data put in, but not taken out - add 1
            fifoWordCount <= fifoWordCount + 1;
    
          (readRun_r && enable_r[i] &&  reqFromNext_r[i] == dataXferToParent):  // no change to counter
            ;
    
          default:
            fifoWordCount <= 'hX;
    
        endcase
       end
     end  // genCounters

endgenerate

`ifdef SIM_ASSERT

  generate
    genvar j;

    for (j = 0; j < numInterfaces; j = j + 1)
     begin
      integer pushPopImbalance;
  
      always @(posedge mclk)
       begin
        if (!readRun_r)
         begin
          pushPopImbalance = 0;
         end
        else if (readRun_r)
         begin
          case (counterError[j])
            1'b0:;  // no error
            default:
             begin
              `SIM_ERROR("push-pull interface error - counter error");
              $display("%t  1 additional info:  error is on interface number %d\n", $time, j);
             end
          endcase
    
          case ({xferToNext[j], reqFromNext_r[j]})
            2'b00,
            2'b11:;  // no change
            2'b01: pushPopImbalance = pushPopImbalance - 1;
            2'b10: pushPopImbalance = pushPopImbalance + 1;
            default:
             begin
              `SIM_ERROR("push-pull interface error - 'xferToNext' and/or 'reqFromNext_r' == x");
              $display("%t  2 additional info:  error is on interface number %d\n", $time, j);
             end
          endcase
    
          if (pushPopImbalance > fifoDepth)
           begin
            `SIM_ERROR("push-pull interface error - too many 'xferToNext' without a 'reqFromNext_r'");
            $display("%t  3 additional info:  error is on interface number %d\n", $time, j);
           end
          else if (pushPopImbalance < 0)
           begin
            `SIM_ERROR("push-pull interface error - more 'reqFromNext_r' than 'xferToNext'");
            $display("%t  4 additional info:  error is on interface number %d\n", $time, j);
           end
          
          if (!enable_r[j] && reqFromNext[j])
           begin
            `SIM_ERROR("push-pull interface error - 'reqFromNext' received on a disabled interface");
            $display("%t  5 additional info:  error is on interface number %d\n", $time, j);
           end

         end
       end
     end

  endgenerate

`endif  // SIM_ASSERT

endmodule
