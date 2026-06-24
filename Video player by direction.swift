import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Binding var player: AVPlayer?
    @Binding var selectedVideoURL: URL?
    @Binding var isPlaying: Bool
    @State private var isShowingImagePicker = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // 背景色を設定
            colorScheme == .dark ? Color.black : Color.white
            
            VStack {
                Text("意識の向け方")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                    .padding(.top, 5)

                Button(action: {
                    self.isShowingImagePicker.toggle()
                }) {
                    Text("映像を選択")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(isPresented: self.$isShowingImagePicker, selectedVideoURL: self.$selectedVideoURL)
                        .edgesIgnoringSafeArea(.all)
                        .onDisappear {
                            if let url = self.selectedVideoURL {
                                self.playVideo(url: url)
                            }
                        }
                }
                
                if let player = self.player {
                    if isPlaying {
                        VideoPlayer(player: player)
                            .onAppear {
                                player.play()
                                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                                    player.seek(to: .zero)
                                    player.play()
                                }
                            }
                    } else {
                        Color.black
                            .onAppear {
                                player.pause()
                            }
                    }
                } else {
                    Text("このアプリでは事前に記録された写真ライブラリ内の画像を使い遠い存在に体を向けて意識したいときや、記録された記憶に深く向き合う時の助けになります。\n 自身のフォルダから存在や記録した映像を選びその方角をあらかじめ設定しておくと、いつでもその事象に自然と体を向けて意識し、思い出すことができます。")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 25)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }

    private func playVideo(url: URL) {
        self.player?.pause() // 停止して前の映像の音声を止める
        self.player = AVPlayer(url: url) // 新しい映像のプレイヤーを作成
        self.isPlaying = true // 新しい映像を再生する準備をする
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedVideoURL: URL?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                parent.selectedVideoURL = videoURL
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
