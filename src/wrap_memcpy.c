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


#include <string.h>
#include <sys/select.h>
#include <setjmp.h>

/* some systems do not have newest memcpy@@GLIBC_2.14 - stay with old good one*/
asm (".symver memcpy, memcpy@GLIBC_2.2.5");
#ifdef __x86_64__
asm (".symver __longjmp_chk, longjmp@GLIBC_2.2.5");
#else
asm (".symver __longjmp_chk, longjmp@GLIBC_2.0");
#endif

void * __wrap_memcpy(void *dest, const void *src, size_t n)
{
  return memcpy(dest, src, n);
}

void __longjmp_chk(jmp_buf env, int val);

void __wrap___longjmp_chk(jmp_buf env, int val)
{
  __longjmp_chk(env, val);
}

void __chk_fail();

/* Older Glibc don't have __fdelt_chk */
/* This is the source from GLIBC 2.17 */
long int __wrap___fdelt_chk (long int d)
{
 if (d < 0 || d >= FD_SETSIZE)
 __chk_fail ();

 return d / __NFDBITS;
}
