//
//  SceneDelegate.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 27/03/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ARViewController()
        window.makeKeyAndVisible()
        self.window = window

        // quando o app abre por um arquivo compartilhado a URL chega aqui
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // se o app já está aberto e recebe outro arquivo entra por esta funcao
        guard let context = URLContexts.first else { return }
        handleIncomingURL(context.url)
    }

    private func handleIncomingURL(_ url: URL) {
        // le o arquivo .person e converte para PersonObject
        guard url.isFileURL,
              let data = try? Data(contentsOf: url),
              let shared = try? JSONDecoder().decode(PersonObject.self, from: data) else { return }

        let storedAudioName: String
        if let audioData = shared.audioData, !audioData.isEmpty {
            // se o payload tiver um áudio ele salva no Documents do app
            let baseName = URL(fileURLWithPath: shared.audio).lastPathComponent
            let originalName = baseName.isEmpty ? "audio.m4a" : baseName
            let ext = URL(fileURLWithPath: originalName).pathExtension
            let extSafe = ext.isEmpty ? "m4a" : ext
            let fileName = "audio_\(UUID().uuidString).\(extSafe)"
            // documents é tipo uma pasta de arquivos do próprio app (local)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(fileName)
            try? audioData.write(to: destinationURL, options: .atomic)
            storedAudioName = fileName
        }
        else {
            // se não vier um audio em bytes ele guarda só a referência recebida
            storedAudioName = shared.audio
        }

        // salva no Core Data pra aparecer na biblioteca
        _ = CoreDataService.shared.createCard(
            name: shared.name,
            id: shared.id,
            lat: shared.lat,
            longe: shared.longe,
            audio: storedAudioName
        )
    }
    


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).

        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
