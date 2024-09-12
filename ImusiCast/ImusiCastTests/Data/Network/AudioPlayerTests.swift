import XCTest
@testable import ImusiCast

class AudioPlayerTests: XCTestCase {
    var audioPlayer: AudioPlayer!

    override func setUp() {
        super.setUp()
        audioPlayer = AudioPlayer()
    }

    override func tearDown() {
        audioPlayer = nil
        super.tearDown()
    }

    func testPlayAudio() {
        let url = URL(string: "https://example.com/audio.mp3")!
        audioPlayer.play(url: url)

        XCTAssertTrue(audioPlayer.isPlaying)
    }

    func testPauseAudio() {
        let url = URL(string: "https://example.com/audio.mp3")!
        audioPlayer.play(url: url)
        audioPlayer.pause()

        XCTAssertFalse(audioPlayer.isPlaying)
    }

    func testResumeAudio() {
        let url = URL(string: "https://example.com/audio.mp3")!
        audioPlayer.play(url: url)
        audioPlayer.pause()
        audioPlayer.resume()

        XCTAssertTrue(audioPlayer.isPlaying)
    }
}
