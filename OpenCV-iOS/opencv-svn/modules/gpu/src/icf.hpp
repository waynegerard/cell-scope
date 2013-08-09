//M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                           License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2008-2012, Willow Garage Inc., all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of the copyright holders may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//M


#ifndef __OPENCV_ICF_HPP__
#define __OPENCV_ICF_HPP__

#include <opencv2/gpu/device/common.hpp>

#if defined __CUDACC__
# define __device __device__ __forceinline__
#else
# define __device
#endif


namespace cv { namespace gpu { namespace device {
namespace icf {

struct Octave
{
    ushort index;
    ushort stages;
    ushort shrinkage;
    ushort2 size;
    float scale;

    Octave(const ushort i, const ushort s, const ushort sh, const ushort2 sz, const float sc)
    : index(i), stages(s), shrinkage(sh), size(sz), scale(sc) {}
};

struct Level //is actually 24 bytes
{
    int octave;
    int step;

    float relScale;
    float scaling[2]; // calculated according to Dollal paper

    // for 640x480 we can not get overflow
    uchar2 workRect;
    uchar2 objSize;

    Level(int idx, const Octave& oct, const float scale, const int w, const int h);
    __device Level(){}
};

struct Node
{
    uchar4 rect;
    // ushort channel;
    unsigned int threshold;

    enum { THRESHOLD_MASK = 0x0FFFFFFF };

    Node(const uchar4 r, const unsigned int ch, const unsigned int t) : rect(r), threshold(t + (ch << 28)) {}
};

struct Detection
{
    ushort x;
    ushort y;
    ushort w;
    ushort h;

    float confidence;
    int kind;

    Detection(){}
    __device Detection(int _x, int _y, uchar _w, uchar _h, float c)
    : x(_x), y(_y), w(_w), h(_h), confidence(c), kind(0) {};
};

struct GK107PolicyX4
{
    enum {WARP = 32, STA_X = WARP, STA_Y = 8, SHRINKAGE = 4};
    typedef float2 roi_type;
    static const dim3 block()
    {
        return dim3(STA_X, STA_Y);
    }
};

template<typename Policy>
struct CascadeInvoker
{
    CascadeInvoker(): levels(0), stages(0), nodes(0), leaves(0), scales(0) {}

    CascadeInvoker(const PtrStepSzb& _levels, const PtrStepSzf& _stages,
                   const PtrStepSzb& _nodes,  const PtrStepSzf& _leaves)
    : levels((const Level*)_levels.ptr()),
      stages((const float*)_stages.ptr()),
      nodes((const Node*)_nodes.ptr()), leaves((const float*)_leaves.ptr()),
      scales(_levels.cols / sizeof(Level))
    {}

    const Level*  levels;
    const float*  stages;

    const Node*   nodes;
    const float*  leaves;

    int scales;

    void operator()(const PtrStepSzb& roi, const PtrStepSzi& hogluv, PtrStepSz<uchar4> objects,
        const int downscales, const cudaStream_t& stream = 0) const;

    template<bool isUp>
    __device void detect(Detection* objects, const unsigned int ndetections, unsigned int* ctr, const int downscales) const;
};

}
}}}

#endif