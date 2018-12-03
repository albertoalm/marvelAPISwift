//
//  Model.swift
//  WebTests
//
//  Created by Dev1 on 30/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import UIKit
import CoreData


struct RootJSON:Codable {
   let etag:String
   struct Data:Codable {
      let count:Int
      struct Results:Codable {
         let id:Int
         let title:String
         let issueNumber:Int
         let variantDescription:String
         let description:String?
         struct Prices:Codable {
            let type:String
            let price:Double
         }
         let prices:[Prices]
         struct Thumbnail:Codable {
            let path:URL
            let imageExtension:String
            enum CodingKeys:String, CodingKey {
               case path
               case imageExtension = "extension"
            }
            var fullPath:URL? {
               var pathComponents = URLComponents(url: path, resolvingAgainstBaseURL: false)
               pathComponents?.scheme = "https"
               return pathComponents?.url?.appendingPathComponent("portrait_incredible").appendingPathExtension(imageExtension)
            }
         }
         let thumbnail:Thumbnail
         struct Creators:Codable {
            let items:[Items]
            struct Items:Codable {
               let name:String
               let role:String
            }
         }
         let creators:Creators
      }
      let results:[Results]
   }
   let data:Data
}



var datosCarga:RootJSON?
var etag:String?

func cargarDatos(datos: Data) {
  
   do {
      let decoder = JSONDecoder()
      //let datosBruto = try Data(contentsOf: rutaBundle)
      guard let datosCoreData = datosCarga else{
         return
      }
      
       datosCarga = try decoder.decode(RootJSON.self, from: datos)
      for datos in ((datosCarga?.data.results)!) {
         let comics = Comics(context: context)
         comics.id = Int32(datos.id)
         comics.title = datos.title
         comics.descripcion = datos.description
         comics.precio = datos.prices.first?.price ?? 0
        
         
         
      }
      
      
      
      
      
      
      
      
        /* comic.id = Int(dato.id)
         persona.nombre = dato.first_name
         persona.apellido = dato.last_name
         persona.email = dato.email
         persona.avatarURL = dato.avatar
         
         let consultaPuesto:NSFetchRequest<Puestos> = Puestos.fetchRequest()
         consultaPuesto.predicate = NSPredicate(format: "jobtitle = %@", dato.jobtitle)
         if let puestoQuery = try? context.fetch(consultaPuesto), let puesto = puestoQuery.first {
            persona.jobtitle = puesto
         } else {
            let puesto = Puestos(context: context)
            puesto.jobtitle = dato.jobtitle
            persona.jobtitle = puesto
         }*/
      
   } catch {
      print("Error en la serialización \(error)")
   }
   saveContext()
}

/*
 func cargar(datos:Data) {
   let decoder = JSONDecoder()
   do {
      datosCarga = try decoder.decode(RootJSON.self, from: datos)
      UserDefaults.standard.set(datosCarga?.etag, forKey: "etag")
      etag = datosCarga?.etag
      NotificationCenter.default.post(name: NSNotification.Name("OKCARGA"), object: nil)
   } catch {
      print("Fallo en la serialización \(error)")
   }
}
*/


func recuperaURL(url:URL, callback:@escaping (UIImage) -> Void) {
   let conexion = URLSession.shared
   conexion.dataTask(with: url) { (data, response, error) in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("Error en la conexión de red \(error.localizedDescription)")
         }
         return
      }
      if response.statusCode == 200 {
         if let imagen = UIImage(data: data) {
            callback(imagen)
         }
      }
      }.resume()
}


var persistentContainer:NSPersistentContainer = {
   let container = NSPersistentContainer(name: "DatosEmpleado")
   container.loadPersistentStores { (storeDescripcion, error) in
      if let error = error as NSError? {
         fatalError("Error inicialización la base de datos")
      }
   }
   return container
}()

var context:NSManagedObjectContext {
   return persistentContainer.viewContext
}

func saveContext() {
   if context.hasChanges {
      do {
         try context.save()
      } catch {
         print("Error en la grabación de la base de datos \(error)")
      }
   }
}
