/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0

Item {
    id: wallpaperFader
    property Item bgForm
    property Item loginForm
    property Item blurSource

    state: lockScreenRoot.uiVisible ? "on" : "off"
    property real factor: 20

    Behavior on factor {
        NumberAnimation {
            target: wallpaperFader
            property: "factor"
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }
    ShaderEffectSource {
        id: blurMask

        sourceItem: blurSource
        width: loginForm.width
        height: parent.height
        anchors.centerIn: loginForm
        sourceRect: Qt.rect(x,y,width,height)
        visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false
    }

    FastBlur {
        id: wallpaperFastBlur

        anchors.centerIn: config.FullBlur == "true" ? parent : loginForm
        height: parent.height
        width: config.FullBlur == "true" ? parent.width : loginForm.width
        radius: config.BlurRadius * wallpaperFader.factor
        //cached: true
        source: config.FullBlur == "true" ? blurSource : blurMask
        visible: ( config.FullBlur == "true" || config.PartialBlur == "true" ) && config.BlurType == "fast" ? true : false
        z: 1
    }

    GaussianBlur {
        id: wallpapperGaussianBlur

        anchors.centerIn: config.FullBlur == "true" ? parent : loginForm
        height: parent.height
        width: config.FullBlur == "true" ? parent.width : loginForm.width
        radius: config.BlurRadius * wallpaperFader.factor
        samples: config.BlurRadius * 2 + 1
        //cached: true
        source: config.FullBlur == "true" ? blurSource : blurMask
        visible: ( config.FullBlur == "true" || config.PartialBlur == "true" ) && config.BlurType == "gaussian" ? true : false
        z: 1
    }

    ShaderEffect {
        id: wallpaperShader
        anchors.fill: parent
        supportsAtlasTextures: true
        property var source: ShaderEffectSource {
            sourceItem: blurSource
            live: true
            hideSource: true
            textureMirroring: ShaderEffectSource.NoMirroring
        }

        readonly property real contrast: 0.45 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real saturation: 1.7 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real intensity: wallpaperFader.factor + (1 - wallpaperFader.factor)

        property var colorMatrix: Qt.matrix4x4(
            contrast, 0,        0,        0.0,
            0,        contrast, 0,        0.0,
            0,        0,        contrast, 0.0,
            0,        0,        0,        1.0).times(Qt.matrix4x4(
                saturation, 0.0,          0.0,        0.0,
                0,          saturation,   0,          0.0,
                0,          0,            saturation, 0.0,
                0,          0,            0,          1.0)).times(Qt.matrix4x4(
                    intensity, 0,         0,         0,
                    0,         intensity, 0,         0,
                    0,         0,         intensity, 0,
                    0,         0,         0,         1
                ));

        fragmentShader: "
            uniform mediump mat4 colorMatrix;
            uniform mediump sampler2D source;
            varying mediump vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;

            void main(void)
            {
                mediump vec4 tex = texture2D(source, qt_TexCoord0);
                gl_FragColor = tex * colorMatrix * qt_Opacity;
            }"
    }

    states: [
        State {
            name: "on"
            PropertyChanges {
              target: bgForm
              opacity: config.PartialBlur == "true" ? 0.3 : 1
            }
            PropertyChanges {
                target: loginForm
                opacity: 1
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 1.0
            }
        },
        State {
            name: "off"
            PropertyChanges {
              target: bgForm
              opacity: 0
            }
            PropertyChanges {
                target: loginForm.input
                opacity: 0
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 0.0
            }
        }
    ]
    transitions: [
        Transition {
            from: "off"
            to: "on"
            //Note: can't use animators as they don't play well with parallelanimations
            ParallelAnimation {
              NumberAnimation {
                  target: bgForm
                  property: "opacity"
                  duration: 1000
                  easing.type: Easing.InOutQuad
              }
                NumberAnimation {
                    target: loginForm.input
                    property: "opacity"
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        },
        Transition {
            from: "on"
            to: "off"
            ParallelAnimation {
              NumberAnimation {
                    target: bgForm
                    property: "opacity"
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: loginForm.input
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]

}
