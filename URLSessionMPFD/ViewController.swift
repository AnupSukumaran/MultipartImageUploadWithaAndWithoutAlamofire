//
//  ViewController.swift
//  URLSessionMPFD
//
//  Created by Sukumar Anup Sukumaran on 05/06/18.
//  Copyright © 2018 TechTonic. All rights reserved.
//

import UIKit
import Alamofire


typealias Parameters = [String: String]

class ViewController: UIViewController {
    
    @IBOutlet weak var imageData: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    @IBAction func getRequest(_ sender: Any) {
        // make url path
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        // make request
        var request = URLRequest(url: url)
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataBody = createDataBody(withParameters: nil, media: nil, boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let response = response {
                print("response = \(response)")
            }
            
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("JSON = \(json)")
                    
                }catch{
                    print("Error = \(error.localizedDescription)")
                }
            }
            
            
        }.resume()
        
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media:[Media]?, boundary:String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
      
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        
        return body
    }
    
    @IBAction func postRequest(_ sender: Any) {
        
        let parameters = ["name": "MytestFile12233", "description":"My tutorial test file"]
        
        guard let image = imageData.image else {
            print("No Image Found")
            return
        }
        
        // the key = "Image" is from the site"Imgur API" that provided the upload link and "Image" was the key name to upload Image
        guard let mediaImage = Media(withImage: image, forKey: "image") else {
            return
        }
        
        // make url path
        guard let url = URL(string: "https://api.imgur.com/3/image") else { return }
        
        // make request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID 779dc20b10234a9", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let response = response {
                print("response = \(response)")
            }
            
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("JSON = \(json)")
                    
                }catch{
                    print("Error = \(error.localizedDescription)")
                }
            }
            
            
            }.resume()
        
        
    }
    
    
    
    @IBAction func uploadingViaAlamofire(_ sender: Any) {
        
        uploadingViaAlamofireMethod()
        
    }
    
    
    func uploadingViaAlamofireMethod() {
        print("uploadingViaAlamofireMethod.....")
        guard let url = URL(string: "https://api.imgur.com/3/image") else { return }
        
        guard let image = imageData.image else {
            print("No Image Found")
            return
        }
        
        guard let mediaImage = Media(withImage: image, forKey: "image") else {
            return
        }
            //let parameters: Parameters = [ "access_token" : "YourToken"]
        let parameters = ["name": "MytestFile12233", "description":"My tutorial test file"]
       // let headers: HTTPHeaders = [ "Client-ID 779dc20b10234a9": "Authorization"]
        let headers: HTTPHeaders = [ "Authorization": "Client-ID 779dc20b10234a9"]
        
        //    let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        //   let fileName = imageURL.absouluteString
            // Start Alamofire
            Alamofire.upload(
                multipartFormData: {
                multipartFormData in
                    
                for (key,value) in parameters {
                    multipartFormData.append((value).data(using: .utf8)!, withName: key)
                }
                    
                multipartFormData.append(mediaImage.data , withName: mediaImage.key, fileName: mediaImage.filename ,mimeType: mediaImage.mimeType)
            }, to: url, method: .post, headers: headers, encodingCompletion: { encodingResult in
                                switch encodingResult {
                               case .success(let upload, _, _):
                                    upload.responseJSON { response in
                                        if let jsonResponse = response.result.value as? [String: Any] {
                                            print("jsonResponse = \(jsonResponse)")
                                        }
                                    }
                                case .failure(let encodingError):
                                    print("encodingError \(encodingError)")
                                }
            })
        
        
        
    }
    
    
    
    
    
    @IBAction func UploadImageData(_ sender: Any) {
        
        pickAnImage(from: .photoLibrary)
    }
    

    func pickAnImage(from source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageData.contentMode = .scaleAspectFit
            imageData.image = image
            
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}


extension Data {
    
   mutating func append(_ string: String) {
        if let data = string.data(using: .utf8){
            append(data)
        }
    }
}

