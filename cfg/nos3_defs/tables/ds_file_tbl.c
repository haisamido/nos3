/************************************************************************
 * NASA Docket No. GSC-18,917-1, and identified as “CFS Data Storage
 * (DS) application version 2.6.1”
 *
 * Copyright (c) 2021 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ************************************************************************/

/**
 * @file
 *   CFS Data Storage (DS) sample destination file table
 *
 * @note
 *   This source file creates a sample table that defines several
 *   data storage destination files using a variety of the options
 *   available. None of the file system details (name, size, etc.)
 *   are known at this time for the target platform. Therefore,
 *   the file pathnames are set to "set_by_cmd_b4_enable" which
 *   indicates that pathnames must be set by command before trying
 *   to enable any of the destination files. Max file size values
 *   should also be modified via command before using this table.
 *
 *   Obviously, a better solution is to replace this sample table
 *   and the sample packet filter table (which references this
 *   table) with mission specific versions that define the data
 *   storage behavior appropriate for the platform.
 *
 *   But, as long as the target platform has a file system, the
 *   sample data storage tables may be used to demonstrate data
 *   storage.
 */

#include "cfe.h"
#include "cfe_tbl_filedef.h"
#include "ds_platform_cfg.h"
#include "ds_extern_typedefs.h"
#include "ds_msg.h"

/*
** Note: It is suggested that missions pre-define their file table
**       index numbers in a public header file to be included by
**       both the packet filter table source file and the destination
**       file table source file. Common definitions may also be used
**       when creating ground system database entries that require
**       file index numbers for command arguments.
*/

/*
** Sample Destination File Table Data
*/
DS_DestFileTable_t DS_DestFileTable = {
    /* .Descriptor = */ "Sample File Table Data",
    /* .File       = */
    {
        /* File Index 00 -- event packets only */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ "/data/evs",
            /* .Basename      = */ "evs",
            /* .Extension     = */ ".ds",

            /* .FileNameType  = */ DS_BY_TIME,
            /* .EnableState   = */ DS_ENABLED,
            /* .MaxFileSize   = */ (1024 * 32), /* 32 K-bytes */
            /* .MaxFileAge    = */ (60 * 45),   /* 45 minutes */
            /* .SequenceCount = */ 1000,
        },
        /* File Index 01 -- application housekeeping packets */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ "/data/cam",
            /* .Basename      = */ "cam",
            /* .Extension     = */ ".ds",

            /* .FileNameType  = */ DS_BY_TIME,
            /* .EnableState   = */ DS_ENABLED,
            /* .MaxFileSize   = */ (1024 * 1024 * 2), /* 2 M-bytes */
            /* .MaxFileAge    = */ (60 * 60 * 2),     /* 2 hours */
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 02 -- application telemetry packets */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ "/data/hk",
            /* .Basename      = */ "hk",
            /* .Extension     = */ ".ds",

            /* .FileNameType  = */ DS_BY_TIME,
            /* .EnableState   = */ DS_ENABLED,
            /* .MaxFileSize   = */ (1024 * 1024 * 1024 * 1), /* 1 G-byte */
            /* .MaxFileAge    = */ (60 * 60 * 2),            /* 2 hours */
            /* .SequenceCount = */ 2000,
        },
        /* File Index 03 -- hardware telemetry packets */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ "/data/inst",
            /* .Basename      = */ "inst",
            /* .Extension     = */ ".ds",

            /* .FileNameType  = */ DS_BY_TIME,
            /* .EnableState   = */ DS_ENABLED,
            /* .MaxFileSize   = */ (1024 * 1024 * 2), /* 2 M-bytes */
            /* .MaxFileAge    = */ (60 * 60 * 2),     /* 2 hours */
            /* .SequenceCount = */ 3000,
        },
        /* File Index 04 -- cFE housekeeping packets */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_BY_COUNT,
            /* .EnableState   = */ DS_DISABLED,
            /* .MaxFileSize   = */ (1024 * 1024 * 2), /* 2 M-bytes */
            /* .MaxFileAge    = */ (60 * 60 * 2),     /* 2 hours */
            /* .SequenceCount = */ 4000,
        },
        /* File Index 05 -- cFE telemetry packets */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_BY_COUNT,
            /* .EnableState   = */ DS_DISABLED,
            /* .MaxFileSize   = */ (1024 * 1024 * 2), /* 2 M-bytes */
            /* .MaxFileAge    = */ (60 * 60 * 2),     /* 2 hours */
            /* .SequenceCount = */ 5000,
        },
        /* File Index 06  - Sample Instrument Data */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ "/data/inst",
            /* .Basename      = */ "id",
            /* .Extension     = */ ".ds",

            /* .FileNameType  = */ DS_BY_TIME,
            /* .EnableState   = */ DS_ENABLED,
            /* .MaxFileSize   = */ (1024 * 1024 * 2), /* 2 M-bytes */
            /* .MaxFileAge    = */ (60 * 60 * 2),     /* 2 hours */
            /* .SequenceCount = */ 6000,
        },
        /* File Index 07 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 08 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 09 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 10 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 11 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 12 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 13 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 14 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
        /* File Index 15 */
        {
#if (DS_MOVE_FILES == true)
            /* .Movename      = */ DS_EMPTY_STRING,
#endif
            /* .Pathname      = */ DS_EMPTY_STRING,
            /* .Basename      = */ DS_EMPTY_STRING,
            /* .Extension     = */ DS_EMPTY_STRING,

            /* .FileNameType  = */ DS_UNUSED,
            /* .EnableState   = */ DS_UNUSED,
            /* .MaxFileSize   = */ DS_UNUSED,
            /* .MaxFileAge    = */ DS_UNUSED,
            /* .SequenceCount = */ DS_UNUSED,
        },
    }};

/*
** Sample Destination File Table Header
*/
CFE_TBL_FILEDEF(DS_DestFileTable, DS.FILE_TBL, DS Destination File Table, ds_file_tbl.tbl)

/************************/
/*  End of File Comment */
/************************/
