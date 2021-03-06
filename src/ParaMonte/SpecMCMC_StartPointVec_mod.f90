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

module SpecMCMC_StartPointVec_mod

    use Constants_mod, only: RK
    implicit none

    character(*), parameter         :: MODULE_NAME = "@SpecMCMC_StartPointVec_mod"

    real(RK), allocatable           :: startPointVec(:) ! namelist input

    type                            :: StartPointVec_type
        real(RK), allocatable       :: Val(:)
        real(RK)                    :: null
        character(:), allocatable   :: desc
    contains
        procedure, pass             :: set => setStartPointVec, checkForSanity, nullifyNameListVar
    end type StartPointVec_type

    interface StartPointVec_type
        module procedure            :: constructStartPointVec
    end interface StartPointVec_type

    private :: constructStartPointVec, setStartPointVec, checkForSanity, nullifyNameListVar

!***********************************************************************************************************************************
!***********************************************************************************************************************************

contains

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    function constructStartPointVec() result(StartPointVecObj)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: constructStartPointVec
#endif
        use Constants_mod, only: NULL_RK
        use String_mod, only: num2str
        implicit none
        type(StartPointVec_type) :: StartPointVecObj
        StartPointVecObj%null   = NULL_RK
        StartPointVecObj%desc   = &
        "startPointVec is a 64bit real-valued vector of length ndim (the dimension of the domain of the input objective function). &
        &For every element of startPointVec that is not provided as input, the default value will be the center of the domain of &
        &startPointVec as specified by randomStartPointDomainLowerLimitVec and randomStartPointDomainUpperLimitVec input variables. &
        &If the input variable RandomStartPointRequested=TRUE (or true or t, all case-insensitive), then the missing &
        &elements of startPointVec will be initialized to values drawn randomly from within the corresponding &
        &ranges specified by the input variables randomStartPointDomainLowerLimitVec and &
        &randomStartPointDomainUpperLimitVec."
    end function constructStartPointVec

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine nullifyNameListVar(StartPointVecObj,nd)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: nullifyNameListVar
#endif
        use Constants_mod, only: IK
        implicit none
        class(StartPointVec_type), intent(in)   :: StartPointVecObj
        integer(IK), intent(in)                 :: nd
        if (allocated(startPointVec)) deallocate(startPointVec)
        allocate(startPointVec(nd), source = StartPointVecObj%null)
    end subroutine nullifyNameListVar

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine setStartPointVec(StartPointVecObj,startPointVec,randomStartPointDomainLowerLimitVec,randomStartPointDomainUpperLimitVec,randomStartPointRequested)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: setStartPointVec
#endif
        use Constants_mod, only: IK, RK
        implicit none
        class(StartPointVec_type), intent(inout)    :: StartPointVecObj
        real(RK), intent(in)                        :: startPointVec(:)
        real(RK), intent(in)                        :: randomStartPointDomainLowerLimitVec(:), randomStartPointDomainUpperLimitVec(:)
        logical, intent(in)                         :: randomStartPointRequested
        real(RK)                                    :: unifrnd
        integer(IK)                                 :: i
        StartPointVecObj%Val = startPointVec
        do i = 1, size(startPointVec)
            if (startPointVec(i)==StartPointVecObj%null) then
                if (randomStartPointRequested) then
                    call random_number(unifrnd)
                    StartPointVecObj%Val(i) = randomStartPointDomainLowerLimitVec(i) + unifrnd * (randomStartPointDomainUpperLimitVec(i)-randomStartPointDomainLowerLimitVec(i))
                else
                    StartPointVecObj%Val(i) = 0.5_RK * ( randomStartPointDomainLowerLimitVec(i) + randomStartPointDomainUpperLimitVec(i) )
                end if
            end if
        end do
    end subroutine setStartPointVec

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine checkForSanity(StartPointVecObj,Err,methodName,randomStartPointDomainLowerLimitVec,randomStartPointDomainUpperLimitVec)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: checkForSanity
#endif
        use Constants_mod, only: IK, RK
        use String_mod, only: num2str
        use Err_mod, only: Err_type
        implicit none
        class(StartPointVec_type), intent(in)   :: StartPointVecObj
        real(RK), intent(in)                    :: randomStartPointDomainLowerLimitVec(:), randomStartPointDomainUpperLimitVec(:)
        character(*), intent(in)                :: methodName
        type(Err_type), intent(inout)           :: Err
        character(*), parameter                 :: PROCEDURE_NAME = "@checkForSanity()"
        integer(IK)                             :: i
        do i = 1, size(StartPointVecObj%Val)
            if ( StartPointVecObj%Val(i)<randomStartPointDomainLowerLimitVec(i) .or. StartPointVecObj%Val(i)>randomStartPointDomainUpperLimitVec(i) ) then
                Err%occurred = .true.
                Err%msg =   Err%msg // &
                            MODULE_NAME // PROCEDURE_NAME // ": Error occurred. &
                            &The input requested value for the component " // num2str(i) // " of the vector startPointVec (" // &
                            num2str(StartPointVecObj%Val(i)) // ") must be within the range of the sampling Domain defined &
                            &in the program: (" &
                            // num2str(randomStartPointDomainLowerLimitVec(i)) // "," &
                            // num2str(randomStartPointDomainUpperLimitVec(i)) // "). If you don't &
                            &know an appropriate value for startPointVec, drop it from the input list. " // &
                            methodName // " will automatically assign an appropriate value to it.\n\n"
            end if
        end do
    end subroutine checkForSanity

!***********************************************************************************************************************************
!***********************************************************************************************************************************

end module SpecMCMC_StartPointVec_mod