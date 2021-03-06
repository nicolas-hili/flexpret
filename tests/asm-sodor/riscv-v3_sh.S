#*****************************************************************************
# riscv_sh.S
#-----------------------------------------------------------------------------
#
# Test sh instruction.
#

#include "test_macros.h"

        TEST_RISCV_BEGIN
        TEST_STATS_BEGIN

        #-------------------------------------------------------------
        # Basic tests
        #-------------------------------------------------------------

        TEST_ST_OP( 2, lh, sh, 0x00000000000000aa, 0, tdat );
        TEST_ST_OP( 3, lh, sh, 0xffffffffffffaa00, 2, tdat );
#ifdef __RISCVEL
        TEST_ST_OP( 4, lw, sh, 0xffffffffbeef0aa0, 4, tdat );
#elif defined(__RISCVEB)
#else
        TEST_ST_OP( 4, lw, sh, 0x000000000aa0beef, 4, tdat );
#error unknown endianness!
#endif
        TEST_ST_OP( 5, lh, sh, 0xffffffffffffa00a, 6, tdat );

        # Test with negative offset

        TEST_ST_OP( 6, lh, sh, 0x00000000000000aa, -6, tdat8 );
        TEST_ST_OP( 7, lh, sh, 0xffffffffffffaa00, -4, tdat8 );
        TEST_ST_OP( 8, lh, sh, 0x0000000000000aa0, -2, tdat8 );
        TEST_ST_OP( 9, lh, sh, 0xffffffffffffa00a, 0,  tdat8 );

        # Test with a negative base

        TEST_CASE( 10, x3, 0x5678, \
          la  x1, tdat9; \
          li  x2, 0x12345678; \
          addi x4, x1, -32; \
          sh x2, 32(x4); \
          lh x3, 0(x1); \
        )

        # Test with unaligned base

        TEST_CASE( 11, x3, 0x3098, \
          la  x1, tdat9; \
          li  x2, 0x00003098; \
          addi x1, x1, -5; \
          sh x2, 7(x1); \
          la  x4, tdat10; \
          lh x3, 0(x4); \
        )

        #-------------------------------------------------------------
        # Bypassing tests
        #-------------------------------------------------------------

        TEST_ST_SRC12_BYPASS( 12, 0, 0, lh, sh, 0xffffffffffffccdd, 0,  tdat );
        TEST_ST_SRC12_BYPASS( 13, 0, 1, lh, sh, 0xffffffffffffbccd, 2,  tdat );
        TEST_ST_SRC12_BYPASS( 14, 0, 2, lh, sh, 0xffffffffffffbbcc, 4,  tdat );
        TEST_ST_SRC12_BYPASS( 15, 1, 0, lh, sh, 0xffffffffffffabbc, 6, tdat );
        TEST_ST_SRC12_BYPASS( 16, 1, 1, lh, sh, 0xffffffffffffaabb, 8, tdat );
        TEST_ST_SRC12_BYPASS( 17, 2, 0, lh, sh, 0xffffffffffffdaab, 10, tdat );

        TEST_ST_SRC21_BYPASS( 18, 0, 0, lh, sh, 0x2233, 0,  tdat );
        TEST_ST_SRC21_BYPASS( 19, 0, 1, lh, sh, 0x1223, 2,  tdat );
        TEST_ST_SRC21_BYPASS( 20, 0, 2, lh, sh, 0x1122, 4,  tdat );
        TEST_ST_SRC21_BYPASS( 21, 1, 0, lh, sh, 0x0112, 6, tdat );
        TEST_ST_SRC21_BYPASS( 22, 1, 1, lh, sh, 0x0011, 8, tdat );
        TEST_ST_SRC21_BYPASS( 23, 2, 0, lh, sh, 0x3001, 10, tdat );

        ##li t0, 0xbeef
        ##la t1, tdat
        ##sh t0, 6(t1)

        # Hack to reset DSPM
        la x2, tdat
        li x3, 0xbeefbeef
        sw x3, 0(x2)
        sw x3, 4(x2)
        sw x3, 8(x2)
        sw x3, 12(x2)
        sw x3, 16(x2)



        TEST_STATS_END
        TEST_PASSFAIL
        TEST_RISCV_END

        #-------------------------------------------------------------
        # Test data
        #-------------------------------------------------------------

        .data
tdat:
tdat1:  .half 0xbeef
tdat2:  .half 0xbeef
tdat3:  .half 0xbeef
tdat4:  .half 0xbeef
tdat5:  .half 0xbeef
tdat6:  .half 0xbeef
tdat7:  .half 0xbeef
tdat8:  .half 0xbeef
tdat9:  .half 0xbeef
tdat10: .half 0xbeef
