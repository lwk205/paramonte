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

module SpecBase_OutputDelimiter_mod

    use Constants_mod, only: IK
    implicit none

    character(*), parameter         :: MODULE_NAME = "@SpecBase_OutputDelimiter_mod"
    integer(IK), parameter          :: MAX_DELIMITER_LEN = 63_IK

    character(:), allocatable       :: outputDelimiter ! namelist input

    type                            :: OutputDelimiter_type
        character(:), allocatable   :: val
        character(:), allocatable   :: def
        character(:), allocatable   :: null
        character(:), allocatable   :: desc
    contains
        procedure, pass             :: set => setOutputDelimiter, checkForSanity, nullifyNameListVar
    end type OutputDelimiter_type

    interface OutputDelimiter_type
        module procedure            :: constructOutputDelimiter
    end interface OutputDelimiter_type

    private :: constructOutputDelimiter, setOutputDelimiter

!***********************************************************************************************************************************
!***********************************************************************************************************************************

contains

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    function constructOutputDelimiter(methodName) result(OutputDelimiterObj)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: constructOutputDelimiter
#endif
        use Constants_mod, only: NULL_SK
        use String_mod, only: num2str
        implicit none
        type(OutputDelimiter_type)  :: OutputDelimiterObj
        character(*), intent(in)    :: methodName
        OutputDelimiterObj%def = ","
        if (allocated(OutputDelimiterObj%null)) deallocate(OutputDelimiterObj%null)
        allocate(character(MAX_DELIMITER_LEN) :: OutputDelimiterObj%null)
        OutputDelimiterObj%null = repeat(NULL_SK, MAX_DELIMITER_LEN)
        OutputDelimiterObj%desc = &
        "outputDelimiter is a string variable, containing a sequence of one or more characters (excluding digits, the period &
        &symbol '.', and the addition and subtraction operators: '+' and '-'), that is used to specify the boundary between &
        &separate, independent information elements in the tabular output files of " // methodName // ". &
        &The string value must be enclosed by either single or double quotation marks when provided as input. &
        &To output in Comma-Separated-Values (CSV) format, set outputDelimiter = ','. If the input value is not provided, &
        &the default delimiter '" // OutputDelimiterObj%def // "' will be used when input outputColumnWidth = 0, and a single &
        &space character, '" // OutputDelimiterObj%def // "' will be used when input outputColumnWidth > 0. &
        &A value of '\t' is interpreted as the TAB character. To avoid this interpretation, use '\\\t' to &
        &yield '\t' without being interpreted as the TAB character. &
        &The default value is '" // OutputDelimiterObj%def // "'."
    end function constructOutputDelimiter

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine nullifyNameListVar(DescriptionObj)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: nullifyNameListVar
#endif
        implicit none
        class(OutputDelimiter_type), intent(inout)  :: DescriptionObj
       !allocate( character(MAX_DELIMITER_LEN) :: outputDelimiter )
        outputDelimiter = DescriptionObj%null
    end subroutine nullifyNameListVar

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine setOutputDelimiter(OutputDelimiterObj,outputDelimiter,outputColumnWidth)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: setOutputDelimiter
#endif
        use Constants_mod, only: TAB
        implicit none
        class(OutputDelimiter_type), intent(inout)  :: OutputDelimiterObj
        character(*), intent(in)                    :: outputDelimiter
        integer(IK) , intent(in)                    :: outputColumnWidth
        OutputDelimiterObj%val = trim(adjustl(outputDelimiter))
        if (OutputDelimiterObj%val==OutputDelimiterObj%null) then
            if (allocated(OutputDelimiterObj%val)) deallocate(OutputDelimiterObj%val)
            if (outputColumnWidth==0_IK) then
                OutputDelimiterObj%val = OutputDelimiterObj%def
            else
                OutputDelimiterObj%val = " "
            end if
        elseif (OutputDelimiterObj%val=="") then
            if (allocated(OutputDelimiterObj%val)) deallocate(OutputDelimiterObj%val)
            OutputDelimiterObj%val = " "
        elseif (OutputDelimiterObj%val=="\t") then
            OutputDelimiterObj%val = TAB
        elseif (OutputDelimiterObj%val=="\\t") then
            OutputDelimiterObj%val = "\t"
        end if
    end subroutine setOutputDelimiter

!***********************************************************************************************************************************
!***********************************************************************************************************************************

    subroutine checkForSanity(OutputDelimiterObj,Err,methodName)
#if defined DLL_ENABLED && !defined CFI_ENABLED
        !DEC$ ATTRIBUTES DLLEXPORT :: checkForSanity
#endif
        use Err_mod, only: Err_type
        use String_mod, only: isDigit
        implicit none
        class(OutputDelimiter_type), intent(in) :: OutputDelimiterObj
        type(Err_type), intent(inout)           :: Err
        character(*), intent(in)                :: methodName
        character(*), parameter                 :: PROCEDURE_NAME = "@checkForSanity()"
        character(:), allocatable               :: delimiter
        integer                                 :: delimiterLen, i
        delimiter = trim(adjustl(OutputDelimiterObj%val))
        delimiterLen = len(delimiter)
        do i = 1, delimiterLen
            if (isDigit(delimiter(i:i)).or.delimiter(i:i)==".".or.delimiter(i:i)=="-".or.delimiter(i:i)=="+") then
                Err%occurred = .true.
                exit
            end if
        end do
        if (Err%occurred) then
            Err%msg =   Err%msg // &
                        MODULE_NAME // PROCEDURE_NAME // ": Error occurred. &
                        &The input value for variable outputDelimiter cannot contain any digits or the period symbol '.' or '-' &
                        &or '+'. If you are unsure about the appropriate value for this variable, simply drop it from the input." &
                        // methodName // " will automatically assign an appropriate value to it.\n\n"
        end if
    end subroutine checkForSanity

!***********************************************************************************************************************************
!***********************************************************************************************************************************

end module SpecBase_OutputDelimiter_mod