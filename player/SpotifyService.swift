//
//  SpotifyService.swift
//  player
//
//  Created by Cameron Bothner on 7/17/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit
import SwiftyJSON

class SpotifyService: SongSearchService {
  static let sharedInstance = SpotifyService()

  var name: String {  get { return "Spotify" }  }
  var message: String {  get { return "Add this song to your “WCBN” playlist" }  }
  var color: String {  get { return "#1ED760" }  }

  var racing: Bool = false
  var currentSong: Song?
  var currentAlbumArtURL: NSURL?
  var currentTrackURI: String?

  var wcbnPlaylistID: String?

  let kClientId = "df271c9e066e4f0d8cbf09567e0c5212"
  let kCallbackURL = NSURL(string: "wcbn-spotify://callback")!
  let kTokenSwapURL = NSURL(string: "https://app.wcbn.org/spotify/swap")!
  let kTokenRefreshURL = NSURL(string: "http://app.wcbn.org/spotify/refresh")!

// MARK: - Authentication

  init() {
    print("Initializing SpotifyService shared instance now.")
    let auth = SPTAuth.defaultInstance()
    auth.sessionUserDefaultsKey = "SpotifySessionUserDefaultsKey"
    auth.clientID = kClientId
    auth.redirectURL = kCallbackURL
    auth.requestedScopes = [
      SPTAuthPlaylistReadPrivateScope,
      SPTAuthPlaylistModifyPublicScope,
      SPTAuthPlaylistModifyPrivateScope
    ]
    auth.tokenSwapURL = kTokenSwapURL
    auth.tokenRefreshURL = kTokenRefreshURL
  }

  private func ensureAuthenticated(callback: () -> ()) {
    let auth = SPTAuth.defaultInstance()

    if auth.session == nil {
      openLoginPage()
    } else if auth.session.isValid() {
      callback()
    } else if auth.hasTokenRefreshService {
      self.renewToken(callback)
    } else {
      openLoginPage()
    }

  }

  private func openLoginPage() {
    let auth = SPTAuth.defaultInstance()

    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    delay(0.1) {
      UIApplication.sharedApplication().openURL(auth.loginURL)
      return
    }
  }

  private func renewToken(then: () -> ()) {
    let auth = SPTAuth.defaultInstance()
    auth.renewSession(auth.session) { error, session in
      auth.session = session

      if ((error) != nil) {
        print("Error renewing session: \(error)")
        self.openLoginPage()
      } else {
        then()
      }
    }
  }

  private func hitSpotifyAPIWithSession(atEndpoint endpointURL: String, containingBody body: JSON = nil, using method: String = "GET", then callback: (JSON) -> Void) {
    let session = SPTAuth.defaultInstance().session
    let authenticationHeader = ["Authorization": "Bearer \(session.accessToken!)"]
    let url = NSURL(string: "https://api.spotify.com/v1\(endpointURL)")!
    hit(url, containingBody: body, using: method, withHeaders: authenticationHeader, then: callback)
  }

// MARK: - Enplaylist
  
  var canEnplaylist: Bool { get {
    return currentTrackURI != nil
  } }

  func enplaylist(then: () -> ()) {
    guard let track = currentTrackURI else { return }
    
    ensureAuthenticated {
      self.getWCBNPlaylistID { id in
        self.addTrackToPlaylist(id, trackURI: track) { error in
          then()
        }
      }
    }
  }

// MARK: Find Playlist
  private func getWCBNPlaylistID(callback: (playlistID: String) -> ()) {
    if let id = wcbnPlaylistID {  return callback(playlistID: id)  }

    hitSpotifyAPIWithSession(atEndpoint: "/me/playlists") { r in
      let playlists = r["items"]

      let wcbnPlaylist_i = playlists.arrayValue.indexOf { playlist in
        return playlist["name"].string == "WCBN"
      }

      if let i = wcbnPlaylist_i {
        self.wcbnPlaylistID = r["items"][i]["id"].stringValue
        print("Spotify: Found playlist \(self.wcbnPlaylistID)")
        callback(playlistID: self.wcbnPlaylistID!)
      }
      else {  self.createWCBNPlaylist(callback)  }
    }
  }

  private func createWCBNPlaylist(callback: (playlistID: String) -> ()) {
    let session = SPTAuth.defaultInstance().session
    let endpoint = "/users/\(session.canonicalUsername!)/playlists"
    let params: JSON = ["name": "WCBN", "public":false]
    hitSpotifyAPIWithSession(atEndpoint: endpoint, containingBody: params, using: "POST") { r in
      self.wcbnPlaylistID = r["id"].stringValue
      print("Spotify: Created playlist \(self.wcbnPlaylistID)")
      callback(playlistID: self.wcbnPlaylistID!)
    }
  }

  // MARK: Add Song to Playlist
  private func addTrackToPlaylist(playlistID: String, trackURI: String, then: () -> ()) {
    let session = SPTAuth.defaultInstance().session
    let endpoint = "/users/\(session.canonicalUsername!)/playlists/\(playlistID)/tracks?position=0&uris=\(trackURI)"
    hitSpotifyAPIWithSession(atEndpoint: endpoint, using: "POST") { r in
      print("Spotify: Added track \(trackURI) to playlist \(playlistID)")
      then()
    }
  }

// MARK: - Lookup

  func lookup(song: Song, then callback: () -> ()) {
    if currentSong != nil && currentSong! == song {
      callback()
    } else {
      ensureAuthenticated {  self.searchSpotify(song, then: callback)  }
    }
  }

  private func searchSpotify(song: Song, then callback: () -> ()) {
    racing = true
    currentSong = song
    fetch(jsonFrom: queryURL(song)) { response in
      let results = response["tracks"]["items"]
      if results.count > 0 {
        print("Spotify: Track found at \(results[0]["uri"])")
        self.currentAlbumArtURL = results[0]["album"]["images"][0]["url"].URL
        self.currentTrackURI = results[0]["uri"].string
      } else {
        print("Spotify: Track not found")
        self.currentAlbumArtURL = nil
        self.currentTrackURI = nil
      }
      self.racing = false
      callback()
    }
  }

  private func queryURL(song: Song) -> NSURL {
    guard let token = SPTAuth.defaultInstance().session.accessToken  else { return NSURL() }
    return NSURL(string: "https://api.spotify.com/v1/search?token=\(token)&type=track&q=\(queryString(song))")!

  }

  private func queryString(song: Song) -> String {
    let q = "track:\(song.name) artist:\(song.artist)"
    return q.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
  }

  var albumArtURL: NSURL? { get {
    return !racing ? currentAlbumArtURL : nil
  } }
}