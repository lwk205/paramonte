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

module SpecBase_VariableNameList_mod

    use Constants_mod, only: IK
    implicit none

    character(*), parameter         :: MODULE_NAME = "@SpecBase_VariableNameList_mod"

    integer(IK), parameter          :: MAX_VARIABLE_NAME_LEN = 63_IK

    character(MAX_VARIABLE_NAME_LEN), allocatable :: variableNameList(:) ! namelist input

    type, private :: MaxLen_type
        integer(IK)                 :: val
        character(:), allocatable   :: str
    end type MaxLen_type

    type :: VariableNameList_type
        character(MAX_VARIABLE_NAME_LEN), allocatable   :: Val(:)
        character(MAX_VARIABLE_NAME_LEN), allocatable   :: Def(:)
        character(MAX_VARIABLE_NAME_LEN)                :: null
        character(:), allocatable                       :: desc
        character(:), allocatable                       :: prefix
        type(MaxLen_type)                               :: MaxLen
    contains
        procedure, pass :: set => setVariableNameList, nullifyNameListVar
    end type VariableNameList_type

    interface VariableNameList_type
        module procedure :: constructVariableNameList
    end interface VariableNameList_type

    private :: constructVariableNameList, setVariableNameList, nullifyNameListVar

!***********************************************************************************************************************************
!***********************************************************************************************************************************

contains

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    function constructVariableNameList(nd,methodName) result(VariableNameListObj)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: constructVariableNameList
#endif
        use Constants_mod, only: IK, NULL_SK
        use String_mod, only: num2str
        implicit none
        integer(IK), intent(in)     :: nd
        character(*), intent(in)    :: methodName
        type(VariableNameList_type) :: VariableNameListObj
        integer                     :: i

        VariableNameListObj%null = repeat(NULL_SK, MAX_VARIABLE_NAME_LEN)

        VariableNameListObj%prefix = "SampleVariable"
        if ( allocated(VariableNameListObj%Def) ) deallocate(VariableNameListObj%Def)
        allocate( VariableNameListObj%Def(nd) )
        do i = 1,nd
            VariableNameListObj%Def(i) = adjustl( VariableNameListObj%prefix//num2str(i) )
        end do

        VariableNameListObj%desc = &
        "variableNameList contains the names of the variables to be sampled by " // methodName // ". &
        &It is used to construct the header of the output sample file. &
        &Any element of variableNameList that is not set by the user will be automatically assigned a default name. &
        &The default value is '" // VariableNameListObj%prefix // "i' where integer 'i' is the index of the variable."
    end function constructVariableNameList

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine nullifyNameListVar(VariableNameListObj,nd)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: nullifyNameListVar
#endif
        use Constants_mod, only: IK
        implicit none
        class(VariableNameList_type), intent(in) :: VariableNameListObj
        integer(IK), intent(in)         :: nd
        if (allocated(variableNameList)) deallocate(variableNameList)
        allocate(variableNameList(nd))
        variableNameList = VariableNameListObj%null
    end subroutine nullifyNameListVar

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine setVariableNameList(VariableNameListObj,variableNameList)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: setVariableNameList
#endif
        use String_mod, only: num2str
        implicit none
        class(VariableNameList_type), intent(inout) :: VariableNameListObj
        character(*), intent(in)                    :: variableNameList(:)
        integer                                     :: i, lentrim
        VariableNameListObj%MaxLen%val = -1
        if ( allocated(VariableNameListObj%Val) ) deallocate(VariableNameListObj%Val)
        allocate( VariableNameListObj%Val, source=VariableNameListObj%Def )
        do i = 1, size(VariableNameListObj%Val)
            if (trim(adjustl(variableNameList(i)))/=trim(adjustl(VariableNameListObj%null))) VariableNameListObj%Val(i) = variableNameList(i)
            lentrim = len_trim(adjustl(VariableNameListObj%Val(i)))
            if (lentrim>VariableNameListObj%MaxLen%val) VariableNameListObj%MaxLen%val = lentrim
        end do
        VariableNameListObj%MaxLen%str = num2str(VariableNameListObj%MaxLen%val)
    end subroutine setVariableNameList

!***********************************************************************************************************************************
!***********************************************************************************************************************************

end module SpecBase_VariableNameList_mod