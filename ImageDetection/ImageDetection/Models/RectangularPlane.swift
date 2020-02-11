//
//  RectangularPlane.swift
//  ImageDetection
//
//  Created by Tim Fosteman on 2020-02-11.
//  Copyright © 2020 Fosteman's Software Solutions LLC. All rights reserved.
//


import simd
import CoreGraphics

extension matrix_float4x4 {
    var simdPos: simd_float3 {
        return simd_float3(position)
    }
}

struct RectangularPlane {
    var center: matrix_float4x4
    var width: CGFloat
    var height: CGFloat
    var length: CGFloat {return 0.005}
    
    init(center: matrix_float4x4, size: CGSize) {
        self.center = center
        self.width = size.width
        self.height = size.height
    }
    
    init(topLeft: matrix_float4x4,
        topRight: matrix_float4x4,
        bottomLeft: matrix_float4x4,
        bottomRight: matrix_float4x4) {
        self.width = CGFloat(simd_distance(topRight.simdPos, topLeft.simdPos))
        self.height = CGFloat(simd_distance(topRight.simdPos, bottomRight.simdPos))
        
        //product of scalar and matrix
        let c1 = simd_mul(0.5, topLeft + bottomRight)
        let c2 = simd_mul(0.5, topRight + bottomLeft)
        self.center = simd_linear_combination(0.5, c1, 0.5, c2)
    }
}
