////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   ParaMonte: plain powerful parallel Monte Carlo library.
//
//   Copyright (C) 2012-present, The Computational Data Science Lab
//
//   This file is part of the ParaMonte library.
//
//   ParaMonte is free software: you can redistribute it and/or modify it
//   under the terms of the GNU Lesser General Public License as published
//   by the Free Software Foundation, version 3 of the License.
//
//   ParaMonte is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//   GNU Lesser General Public License for more details.
//
//   You should have received a copy of the GNU Lesser General Public License
//   along with the ParaMonte library. If not, see,
//
//       https://github.com/cdslaborg/paramonte/blob/master/LICENSE
//
//   ACKNOWLEDGMENT
//
//   As per the ParaMonte library license agreement terms,
//   if you use any parts of this library for any purposes,
//   we ask you to acknowledge the use of the ParaMonte library
//   in your work (education/research/industry/development/...)
//   by citing the ParaMonte library as described on this page:
//
//       https://github.com/cdslaborg/paramonte/blob/master/ACKNOWLEDGMENT.md
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <math.h>
#include <stdint.h>
#include <string.h>

#ifndef PM_LOG_FUNC
#define PM_LOG_FUNC
double getLogFunc   (
                    int32_t ,   // ndim
                    double []   // Point
                    );
#endif

#ifndef PM_LOG_FUNC_WRAPPER
#define PM_LOG_FUNC_WRAPPER
double getLogFuncWrapper(
                        int32_t ,   // ndim
                        double []   // Point
                        );
#endif

#ifndef ParaMonte
#define ParaMonte
int32_t runParaDRAM (
                    // ndim: dimension of the domain of the LogFunc
                    int32_t ,
                    // getLogFunc(ndim, Point(ndim)): procedure pointer to the LogFunc
                    double (*)  (
                                int32_t ,
                                double []
                                ),
                    // inputFilePtr: ParaMonte input file path string, containing a list of all optional input variables and values
                    char [],
                    // inputFilePtrLen: the length of the inputFilePtr char vector: int32_t inputFilePtrLen = strlen(inputFilePtr);
                    int32_t
                    );
#endif

//**********************************************************************************************************************************
//**********************************************************************************************************************************

#include "mex.h"
#if defined _WIN32
#include <Windows.h>
#endif

#define	MEX_ISCMD       prhs[0]
#define MEX_NDIM        prhs[1]
#define MEX_INPUTFILE   prhs[2]
#define MEX_GETLOGFUNC  prhs[3]

mxArray *MEX_GETLOGFUNC_HANDLE;

void mexFunction( int nlhs
                , mxArray *plhs[]
                , int nrhs
                , const mxArray *prhs[]
                )
{

//#if defined _WIN32
//    int iscmd = mxGetScalar(MEX_ISCMD);
//    if (iscmd==0) {
//        if (AllocConsole()==0) {
//            freopen("CONOUT$", "w", stdout);
//            freopen("CONOUT$", "w", stderr);
//        }
//    }
//#endif

    /********************************************check for proper number of arguments**********************************************/

    int isAnnonymous = 0;
    if (nrhs==4) {
        if(!mxIsClass(MEX_GETLOGFUNC,"function_handle")) mexErrMsgTxt("First input argument is not a function handle.");
        MEX_GETLOGFUNC_HANDLE = mxDuplicateArray(MEX_GETLOGFUNC);
        isAnnonymous = 1;
    } else {
        if (nrhs!=3) mexErrMsgIdAndTxt( "Mex:ParaMonte:invalidNumInputs", "Internal ParaMonte library error occurred: input variable mismatch.");
    }
    if(nlhs>0) mexErrMsgIdAndTxt( "Mex:ParaMonte:maxlhs", "Internal ParaMonte library error occurred: Too many output arguments.");

    /******************************************************************************************************************************/
    /******************************************************************************************************************************/

    int32_t ndim = mxGetScalar(MEX_NDIM);

    if (mxIsChar(MEX_INPUTFILE) != 1) mexErrMsgIdAndTxt( "Mex:ParaMonte:inputNotString", "Internal ParaMonte library error occurred: Input #3 must be a string.");
    if (mxGetM(MEX_INPUTFILE)!=1) mexErrMsgIdAndTxt( "Mex:ParaMonte:inputNotVector", "Input must be a row vector.");

    char *inputFilePtr;
    inputFilePtr = mxArrayToString(MEX_INPUTFILE);
    if(inputFilePtr == NULL) mexErrMsgIdAndTxt( "Mex:ParaMonte:conversionFailed", "Internal ParaMonte library error occurred: Could not convert input #2 to string.");

    size_t inputFilePtrLen;
    inputFilePtrLen = (mxGetM(MEX_INPUTFILE) * mxGetN(MEX_INPUTFILE)) + 1;

    /******************************************************************************************************************************/
    /******************************************************************************************************************************/

    int32_t err;
    if (isAnnonymous==1) {
        err = runParaDRAM   ( ndim
                            , &getLogFuncWrapper
                            , inputFilePtr
                            , inputFilePtrLen
                            );
    } else {
        err = runParaDRAM   ( ndim
                            , &getLogFunc
                            , inputFilePtr
                            , inputFilePtrLen
                            );
    }
    if (err!=0) mexErrMsgIdAndTxt( "Mex:ParaMonte", "Runtime Error Occurred.");

    mxFree(inputFilePtr);

    return;
}

/**********************************************************************************************************************************/
/**********************************************************************************************************************************/

double getLogFunc   (
                    int32_t ndim,
                    double *Point
                    )
{
    mxArray *InputArg2getLogFunc[1];
    InputArg2getLogFunc[0] = mxCreateDoubleMatrix(ndim, 1, mxREAL);
    memcpy( mxGetPr(InputArg2getLogFunc[0]), Point, ndim*sizeof(double));

    mxArray *logFuncRaw[1];
    mexCallMATLAB(1,logFuncRaw,1,InputArg2getLogFunc,"getLogFunc");
    double logFunc = mxGetScalar( logFuncRaw[0] );

    return logFunc;
}

//**********************************************************************************************************************************
//**********************************************************************************************************************************

double getLogFuncWrapper(
                        int32_t ndim,
                        double *Point
                        )
{
    mxArray *InputArg2feval[2];
    InputArg2feval[0] = MEX_GETLOGFUNC_HANDLE;
    InputArg2feval[1] = mxCreateDoubleMatrix(ndim, 1, mxREAL);
    memcpy( mxGetPr(InputArg2feval[1]), Point, ndim*sizeof(double));

    mxArray *logFuncRaw[1];
    mexCallMATLAB(1,logFuncRaw,2,InputArg2feval,"feval");
    double logFunc = mxGetScalar( logFuncRaw[0] );

    return logFunc;
}
