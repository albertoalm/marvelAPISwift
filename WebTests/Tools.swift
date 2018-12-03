//
//  Tools.swift
//  WebTests
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import Foundation
import CommonCrypto

let publicKey = "ae4ff7f58cd44114fe2049f565e9c60c"
let privateKey = "644b11844d29e62f98227d861c457ac0b7fd66be"

var baseURL = URL(string: "https://gateway.marvel.com/v1/public")!

func conexionMarvel() {
   let ts = "\(Date().timeIntervalSince1970)"
   let valorFirmar = ts+privateKey+publicKey
   let queryts = URLQueryItem(name: "ts", value: ts)
   let queryApikey = URLQueryItem(name: "apikey", value: publicKey)
   let queryHash = URLQueryItem(name: "hash", value: valorFirmar.MD5)
   let queryLimit = URLQueryItem(name: "limit", value: "100")
   let queryOrder = URLQueryItem(name: "orderBy", value: "onsaleDate")
   let queryFormat = URLQueryItem(name: "format", value: "hardcover")
   
   var url = URLComponents()
   url.scheme = baseURL.scheme
   url.host = baseURL.host
   url.path = baseURL.path
   url.queryItems = [queryts, queryApikey, queryHash, queryLimit, queryOrder, queryFormat]
   
   let session = URLSession.shared
   var request = URLRequest(url: url.url!.appendingPathComponent("comics"))
   request.httpMethod = "GET"
   request.addValue("*/*", forHTTPHeaderField: "Accept")
//   if let etag = etag {
//      request.addValue(etag, forHTTPHeaderField: "If-None-Match")
//   }
   session.dataTask(with: request) { (data, response, error) in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("Error en la comunicación \(error)")
         }
         return
      }
      if response.statusCode == 200 {
         //print(String(data: data, encoding: .utf8)!)
         cargar(datos: data)
      } else {
         print(response.statusCode)
      }
   }.resume()
}

func getDateTime() -> String {
   let fecha = Date()
   let formatter = DateFormatter()
   formatter.dateFormat = "ddMMyyyyhhmmss"
   return formatter.string(from: fecha)
}

extension String {
   var MD5:String? {
      guard let messageData = self.data(using: .utf8) else {
         return nil
      }
      var datoMD5 = Data(count: Int(CC_MD5_DIGEST_LENGTH))
      _ = datoMD5.withUnsafeMutableBytes { bytes in
         messageData.withUnsafeBytes { messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), bytes)
         }
      }
      var MD5String = String()
      for c in datoMD5 {
         MD5String += String(format: "%02x", c)
      }
      return MD5String
   }
}
