!***********************************************************************************************************************************
!***********************************************************************************************************************************
!
!   ParaMonte: plain powerful parallel Monte Carlo library.
!
!   Copyright (C) 2012-present, The Computational Data Science Lab
!
!   This file is part of the ParaMonte library.
!
!   ParaMonte is free software: you can redistribute it and/or modify it
!   under the terms of the GNU Lesser General Public License as published
!   by the Free Software Foundation, version 3 of the License.
!
!   ParaMonte is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!   GNU Lesser General Public License for more details.
!
!   You should have received a copy of the GNU Lesser General Public License
!   along with the ParaMonte library. If not, see,
!
!       https://github.com/cdslaborg/paramonte/blob/master/LICENSE
!
!   ACKNOWLEDGMENT
!
!   As per the ParaMonte library license agreement terms,
!   if you use any parts of this library for any purposes,
!   we ask you to acknowledge the use of the ParaMonte library
!   in your work (education/research/industry/development/...)
!   by citing the ParaMonte library as described on this page:
!
!       https://github.com/cdslaborg/paramonte/blob/master/ACKNOWLEDGMENT.md
!
!***********************************************************************************************************************************
!***********************************************************************************************************************************

module Misc_mod

    use, intrinsic :: iso_fortran_env, only: int32
    implicit none

    integer(int32), PARAMETER :: NPAR_ARTH = 16, NPAR2_ARTH = 8

    interface copyArray
        module procedure :: copyArray_IK, copyArray_RK
    end interface copyArray

    interface arth
        module procedure :: arth_RK, arth_IK
    end interface arth

    interface swap
        !module procedure :: swap_CK, swap_RK, swap_IK    !, swap_vec_RK
        module procedure :: swap_SPI, swap_DPI, swap_SPR, swap_DPR, swap_SPC, swap_DPC    ! , swap_cm, swap_z, swap_rv, swap_cv
        module procedure :: masked_swap_SPR, masked_swap_SPRV, masked_swap_SPRM ! swap_zv, swap_zm
    end interface swap

!***********************************************************************************************************************************
!***********************************************************************************************************************************

contains

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    pure elemental subroutine swap_CK(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_CK
#endif
        use Constants_mod, only: CK
        implicit none
        complex(CK), intent(inout)  :: a,b
        complex(CK)                 :: dummy
        dummy = a
        a = b
        b = dummy
    end subroutine swap_CK

    pure elemental subroutine swap_RK(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_RK
#endif
        use Constants_mod, only: RK
        implicit none
        real(RK), intent(inout) :: a,b
        real(RK)                :: dummy
        dummy = a
        a = b
        b = dummy
    end subroutine swap_RK

    pure elemental subroutine swap_IK(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_IK
#endif
        use Constants_mod, only: IK
        implicit none
        integer(IK), intent(inout) :: a,b
        integer(IK)                :: dummy
        dummy = a
        a = b
        b = dummy
    end subroutine swap_IK

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    pure elemental subroutine swap_SPI(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_SPI
#endif
        use Constants_mod, only: SPI
        implicit none
        integer(SPI), intent(inout) :: a,b
        integer(SPI) :: dum
        dum=a
        a=b
        b=dum
    end subroutine swap_SPI

    pure elemental subroutine swap_DPI(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_DPI
#endif
        use Constants_mod, only: DPI
        implicit none
        integer(DPI), intent(inout) :: a,b
        integer(DPI) :: dum
        dum=a
        a=b
        b=dum
    end subroutine swap_DPI

    pure elemental subroutine swap_SPR(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_SPR
#endif
        use Constants_mod, only: SPR
        implicit none
        real(SPR), intent(inout) :: a,b
        real(SPR) :: dum
        dum=a
        a=b
        b=dum
    end subroutine swap_SPR

    pure elemental subroutine swap_DPR(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_DPR
#endif
        use Constants_mod, only: DPR
        implicit none
        real(DPR), intent(inout) :: a,b
        real(DPR) :: dum
        dum=a
        a=b
        b=dum
    end subroutine swap_DPR

    !pure subroutine swap_rv(a,b)
    !    use Constants_mod, only: SPR
    !    implicit none
    !    real(SPR), dimension(:), intent(inout) :: a,b
    !    real(SPR), dimension(size(a)) :: dum
    !    dum=a
    !    a=b
    !    b=dum
    !end subroutine swap_rv

    pure elemental subroutine swap_SPC(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_SPC
#endif
        use Constants_mod, only: SPC
        implicit none
        complex(SPC), intent(inout) :: a,b
        complex(SPC) :: dum
        dum=a
        a=b
        b=dum
    end subroutine swap_SPC

    pure elemental subroutine swap_DPC(a,b)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: swap_DPC
#endif
        use Constants_mod, only: DPC
        implicit none
        complex(DPC), intent(inout) :: a,b
        complex(DPC) :: dum
        dum=a
        a=b
        b=dum
    end subroutine swap_DPC

    !pure subroutine swap_cv(a,b)
    !    use Constants_mod, only: SPC
    !    implicit none
    !    complex(SPC), dimension(:), intent(inout) :: a,b
    !    complex(SPC), dimension(size(a)) :: dum
    !    dum=a
    !    a=b
    !    b=dum
    !end subroutine swap_cv

    !pure subroutine swap_cm(a,b)
    !    use Constants_mod, only: SPC
    !    implicit none
    !    complex(SPC), dimension(:,:), intent(inout) :: a,b
    !    complex(SPC), dimension(size(a,1),size(a,2)) :: dum
    !    dum=a
    !    a=b
    !    b=dum
    !end subroutine swap_cm

    !pure subroutine swap_z(a,b)
    !    use Constants_mod, only: DPC
    !    implicit none    
    !    complex(DPC), intent(inout) :: a,b
    !    complex(DPC) :: dum
    !    dum=a
    !    a=b
    !    b=dum
    !end subroutine swap_z

    !pure subroutine swap_zv(a,b)
    !    use Constants_mod, only: DPC
    !    implicit none    
    !    complex(DPC), dimension(:), intent(inout) :: a,b
    !    complex(DPC), dimension(size(a)) :: dum
    !    dum=a
    !    a=b
    !    b=dum
    !end subroutine swap_zv

    !pure subroutine swap_zm(a,b)
    !    use Constants_mod, only: DPC
    !    implicit none    
    !    complex(DPC), dimension(:,:), intent(inout) :: a,b
    !    complex(DPC), dimension(size(a,1),size(a,2)) :: dum
    !    dum=a
    !    a=b
    !    b=dum
    !end subroutine swap_zm

    pure subroutine masked_swap_SPR(a,b,mask)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: masked_swap_SPR
#endif
        use Constants_mod, only: SPR
        implicit none    
        real(SPR), intent(inout) :: a,b
        logical, intent(in) :: mask
        real(SPR) :: swp
        if (mask) then
            swp=a
            a=b
            b=swp
        end if
    end subroutine masked_swap_SPR

    pure subroutine masked_swap_SPRV(a,b,mask)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: masked_swap_SPRV
#endif
        use Constants_mod, only: SPR
        implicit none    
        real(SPR), dimension(:), intent(inout) :: a,b
        logical, dimension(:), intent(in) :: mask
        real(SPR), dimension(size(a)) :: swp
        where (mask)
            swp=a
            a=b
            b=swp
        end where
    end subroutine masked_swap_SPRV

    pure subroutine masked_swap_SPRM(a,b,mask)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: masked_swap_SPRM
#endif
        use Constants_mod, only: SPR
        implicit none    
        real(SPR), dimension(:,:), intent(inout) :: a,b
        logical, dimension(:,:), intent(in) :: mask
        real(SPR), dimension(size(a,1),size(a,2)) :: swp
        where (mask)
            swp=a
            a=b
            b=swp
        end where
    end subroutine masked_swap_SPRM

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    pure function arth_RK(first,increment,n) result(arth)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: arth_RK
#endif
        ! returns an arithmetic progression as an array
        use Constants_mod, only: IK, RK
        real(RK)    , intent(in)    :: first,increment
        integer(IK) , intent(in)    :: n
        real(RK)                    :: arth(n)
        integer(IK)                 :: k,k2
        real(RK)                    :: temp
        if (n > 0) arth(1)=first
        if (n <= npar_arth) then
            do k = 2,n
                arth(k) = arth(k-1) + increment
            end do
        else
            do k = 2, npar2_arth
                arth(k) = arth(k-1) + increment
            end do
            temp = increment * npar2_arth
            k = npar2_arth
            do
                if (k >= n) exit
                k2 = k+k
                arth(k+1:min(k2,n)) = temp + arth(1:min(k,n-k))
                temp = temp + temp
                k = k2
            end do
        end if
    end function arth_RK

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    pure function arth_IK(first,increment,n) result(arth)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: arth_IK
#endif
        ! returns an arithmetic progression as an array
        use Constants_mod, only: IK, RK
        integer(IK) , intent(in)    :: first,increment,n
        integer(IK)                 :: arth(n)
        integer(IK)                 :: k,k2,temp
        if (n > 0) arth(1) = first
        if (n <= npar_arth) then
            do k=2,n
                arth(k) = arth(k-1) + increment
            end do
        else
            do k = 2, npar2_arth
                arth(k) = arth(k-1) + increment
            end do
            temp = increment * npar2_arth
            k = npar2_arth
            do
                if (k >= n) exit
                k2 = k + k
                arth(k+1:min(k2,n)) = temp+arth(1:min(k,n-k))
                temp = temp + temp
                k = k2
            end do
        end if
    end function arth_IK

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    pure function zroots_unity(n,nn)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: zroots_unity
#endif
        use Constants_mod, only: IK, RK, CK, TWOPI
        implicit none
        integer(IK), intent(in)  :: n,nn
        complex(CK)              :: zroots_unity(nn)
        integer(IK)              :: k
        real(RK)                 :: theta
        zroots_unity(1) = 1.0
        theta = TWOPI / n
        k = 1
        do
            if (k >= nn) exit
            zroots_unity(k+1) = cmplx(cos(k*theta),sin(k*theta),CK)
            zroots_unity(k+2:min(2*k,nn)) = zroots_unity(k+1) * zroots_unity(2:min(k,nn-k))
            k = 2 * k
        end do
    end function zroots_unity

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine copyArray_RK(Source,Destination,numCopied,numNotCopied)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: copyArray_RK
#endif
        use Constants_mod, only: IK, RK
        implicit none
        real(RK), intent(in)        :: Source(:)
        real(RK), intent(out)       :: Destination(:)
        integer(IK), intent(out)    :: numCopied, numNotCopied
        numCopied = min(size(Source),size(Destination))
        numNotCopied = size(Source) - numCopied
        Destination(1:numCopied) = Source(1:numCopied)
    end subroutine copyArray_RK

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine copyArray_IK(Source,Destination,numCopied,numNotCopied)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: copyArray_IK
#endif
        use Constants_mod, only: IK
        implicit none
        integer(IK), intent(in)     :: Source(:)
        integer(IK), intent(out)    :: Destination(:)
        integer(IK), intent(out)    :: numCopied, numNotCopied
        numCopied = min(size(Source),size(Destination))
        numNotCopied = size(Source) - numCopied
        Destination(1:numCopied) = Source(1:numCopied)
    end subroutine copyArray_IK

!***********************************************************************************************************************************
!***********************************************************************************************************************************

end module Misc_mod