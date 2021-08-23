//
// This file is part of SDDM Sugar Candy.
// A theme for the Simple Display Desktop Manager.
//
// Copyright (C) 2018–2020 Marian Arlt
//
// SDDM Sugar Candy is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or any later version.
//
// You are required to preserve this and any additional legal notices, either
// contained in this file or in other files that you received along with
// SDDM Sugar Candy that refer to the author(s) in accordance with
// sections §4, §5 and specifically §7b of the GNU General Public License.
//
// SDDM Sugar Candy is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SDDM Sugar Candy. If not, see <https://www.gnu.org/licenses/>
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import QtMultimedia 5.7
import "Components"

Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.ScreenWidth

    LayoutMirroring.enabled: config.ForceRightToLeft == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    padding: config.ScreenPadding
    palette.button: "transparent"
    palette.highlight: config.AccentColor
    palette.text: config.MainColor
    palette.buttonText: config.MainColor
    palette.window: config.BackgroundColor

    font.family: config.Font
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80)
    focus: true

    property bool leftleft: config.HaveFormBackground == "true" &&
                            config.PartialBlur == "false" &&
                            config.FormPosition == "left" &&
                            config.BackgroundImageHAlignment == "left"

    property bool leftcenter: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "left" &&
                              config.BackgroundImageHAlignment == "center"

    property bool rightright: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "right" &&
                              config.BackgroundImageHAlignment == "right"

    property bool rightcenter: config.HaveFormBackground == "true" &&
                               config.PartialBlur == "false" &&
                               config.FormPosition == "right" &&
                               config.BackgroundImageHAlignment == "center"

    Item {
        id: sizeHelper

        anchors.fill: parent
        height: parent.height
        width: parent.width

///     LoginForm BackgroundColor
        Rectangle {
            id: formBackground
            anchors.fill: form
            anchors.centerIn: form
            color: root.palette.window
            visible: config.HaveFormBackground == "true" ? true : false
            opacity: config.PartialBlur == "true" ? 0.3 : 1
            z: 1
        }

        LoginForm {
            id: form

            layer.smooth: enable
            height: virtualKeyboard.state == "visible" ? parent.height - virtualKeyboard.implicitHeight : parent.height
            width: parent.width / 3.25
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined
            anchors.left: config.FormPosition == "left" ? parent.left : undefined
            anchors.right: config.FormPosition == "right" ? parent.right : undefined
            virtualKeyboardActive: virtualKeyboard.state == "visible" ? true : false
            state: "off"
            z: 1
        }

///     VirtualKeyboard
        Button {
            id: vkb
            onClicked: virtualKeyboard.switchState()
            visible: virtualKeyboard.status == Loader.Ready && config.ForceHideVirtualKeyboardButton == "false"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: implicitHeight
            anchors.horizontalCenter: form.horizontalCenter
            z: 1
            contentItem: Text {
                text: config.TranslateVirtualKeyboardButton || "Virtual Keyboard"
                color: parent.visualFocus ? palette.highlight : palette.text
                font.pointSize: root.font.pointSize * 0.8
            }
            background: Rectangle {
                id: vkbbg
                color: "transparent"
            }
        }
        Loader {
            id: virtualKeyboard
            source: "Components/VirtualKeyboard.qml"
            state: "hidden"
            property bool keyboardActive: item ? item.active : false
            onKeyboardActiveChanged: keyboardActive ? state = "visible" : state = "hidden"
            width: parent.width
            z: 1
            function switchState() { state = state == "hidden" ? "visible" : "hidden" }
            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: form
                        systemButtonVisibility: false
                        clockVisibility: false
                    }
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - virtualKeyboard.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - root.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                virtualKeyboard.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

///     BackgroundDimmer
        Rectangle {
            id: tintLayer
            anchors.fill: parent
            width: parent.width
            height: parent.height
            color: "black"
            opacity: config.DimBackgroundImage
            z: 1
        }

///     backgroud
        Item{
          id: background
          anchors.fill: parent

          // backgroundImage
          Image {
            id: backgroundImage

            height: parent.height
            width: config.HaveFormBackground == "true" && config.FormPosition != "center" && config.PartialBlur != "true" ? parent.width - formBackground.width : parent.width
            anchors.left: leftleft ||
                          leftcenter ?
                                formBackground.right : undefined

            anchors.right: rightright ||
                           rightcenter ?
                                formBackground.left : undefined

            horizontalAlignment: config.BackgroundImageHAlignment == "left" ?
                                 Image.AlignLeft :
                                 config.BackgroundImageHAlignment == "right" ?
                                 Image.AlignRight : Image.AlignHCenter

            verticalAlignment: config.BackgroundImageVAlignment == "top" ?
                               Image.AlignTop :
                               config.BackgroundImageVAlignment == "bottom" ?
                               Image.AlignBottom : Image.AlignVCenter

            //source: config.background_img_day || config.background_img_night
            fillMode: config.ScaleImageCropped == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            asynchronous: true
            cache: true
            clip: true
            mipmap: true
          }

          // Set Background Video1
          MediaPlayer {
              id: mediaplayer1
              autoPlay: true; muted: true
              playlist: Playlist {
                  id: playlist1
                  playbackMode: Playlist.Random
                  onLoaded: { mediaplayer1.play() }
              }
          }
          VideoOutput {
              id: video1
              fillMode: VideoOutput.PreserveAspectCrop
              anchors.fill: parent; source: mediaplayer1
              MouseArea {
                  id: mouseArea1
                  anchors.fill: parent;
                  //onPressed: {playlist1.shuffle(); playlist1.next();}
                  onPressed: {
                      fader1.state = fader1.state == "off" ? "on" : "off" ;
                      if (config.autofocusInput == "true") {
                          if (username_input_box.text == "")
                              username_input_box.focus = true
                          else
                              password_input_box.focus = true
                      }
                  }
              }
              Keys.onPressed: {
                  fader.state = "on";
                  if (username_input_box.text == "")
                      username_input_box.focus = true
                  else
                      password_input_box.focus = true
              }
          }

          // Set Background Video2
          MediaPlayer {
              id: mediaplayer2
              autoPlay: true; muted: true
              playlist: Playlist {
                  id: playlist2; playbackMode: Playlist.Random
                  //onLoaded: { mediaplayer2.play() }
              }
          }
          VideoOutput {
              id: video2
              fillMode: VideoOutput.PreserveAspectCrop
              anchors.fill: parent; source: mediaplayer2
              opacity: 0
              MouseArea {
                  id: mouseArea2
                  enabled: false
                  anchors.fill: parent;
                  onPressed: {
                      fader1.state = fader1.state == "off" ? "on" : "off" ;
                      if (config.autofocusInput == "true") {
                          if (username_input_box.text == "")
                              username_input_box.focus = true
                          else
                              password_input_box.focus = true
                      }
                  }
              }
              Behavior on opacity {
                  enabled: true
                  NumberAnimation { easing.type: Easing.InOutQuad; duration: 3000 }
              }
              Keys.onPressed: {
                  fader2.state = "on";
                  if (username_input_box.text == "")
                      username_input_box.focus = true
                  else
                      password_input_box.focus = true
              }
          }

        }

        WallpaperFader {
            id: fader
            visible: true
            anchors.fill: parent
            state: "off"
            blurSource: background
            bgForm: formBackground
            loginForm: form
        }

        property MediaPlayer currentPlayer: mediaplayer1

        // Timer event to handle fade between videos
        Timer {
            interval: 1000;
            running: true; repeat: true
            onTriggered: {
                if (currentPlayer.duration != -1 && currentPlayer.position > currentPlayer.duration - 10000) { // pre load the 2nd player
                    if (video2.opacity == 0) { // toogle opacity
                        mediaplayer2.play()
                    } else
                        mediaplayer1.play()
                }
                if (currentPlayer.duration != -1 && currentPlayer.position > currentPlayer.duration - 3000) { // initiate transition
                    if (video2.opacity == 0) { // toogle opacity
                        mouseArea1.enabled = false
                        currentPlayer = mediaplayer2
                        video2.opacity = 1
                        triggerTimer.start()
                        mouseArea2.enabled = true
                    } else {
                        mouseArea2.enabled = false
                        currentPlayer = mediaplayer1
                        video2.opacity = 0
                        triggerTimer.start()
                        mouseArea1.enabled = true
                    }
                }
            }
        }

        // this timer waits for fade to stop and stops the video
        Timer {
            id: triggerTimer
            interval: 4000; running: false; repeat: false
            onTriggered: {
                if (video2.opacity == 1)
                    mediaplayer1.stop()
                else
                    mediaplayer2.stop()
            }
        }

        //
        MouseArea {
            anchors.fill: parent
            z: 0
            onPressed: {
              parent.forceActiveFocus();
              //form.inputVisibility = form.inputVisibility == true ? false:true;
              fader.state = fader.state == "off" ? "on" : "off" ;
              form.state = fader.state ;

            }
        }
        Keys.onPressed: {
            fader.state = "on";
            form.state = fader.state ;
            if (username.text == "")
                username.focus = true
            else
                password.focus = true
        }
      }
      Component.onCompleted: {

          video1.focus = true

          // load and randomize playlist
          var time = parseInt(new Date().toLocaleTimeString(Qt.locale(),'h'))
          if ( time >= 5 && time <= 17 ) {
              playlist1.load(Qt.resolvedUrl(config.background_vid_day), 'm3u')
              playlist2.load(Qt.resolvedUrl(config.background_vid_day), 'm3u')
              backgroundImage.source = config.background_img_day
          } else {
              playlist1.load(Qt.resolvedUrl(config.background_vid_night), 'm3u')
              playlist2.load(Qt.resolvedUrl(config.background_vid_night), 'm3u')
              backgroundImage.source = config.background_img_night
          }

          for (var k = 0; k < Math.ceil(Math.random() * 10) ; k++) {
              playlist1.shuffle()
              playlist2.shuffle()
          }

      }
}
