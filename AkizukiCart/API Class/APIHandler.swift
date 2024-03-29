//
//  APIHandler.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import Foundation
import Alamofire
import RxSwift
import RxRelay

// MARK: - ダウンロード状態
enum DownloadState {
    case loading
    case finish(PartsInfo)
    case failure(FailureResult)
}

// MARK: - Protocol
protocol APIHandlerProtocol {
    /// ダウンロード状態
    var downloadStateObservable: Observable<DownloadState> { get }
    /// 単品のダウンロード
    func fetchItem(_ item: String)
}

class APIHandler: APIHandlerProtocol {
    /// 指定されたアイテム番号で商品を検索する
    /// - Parameters:
    ///   - item: ^[MKPBRSICT]-[0-9]{5}$.json 形式のアイテム番号
    ///   - successHandler: 検索成功時の処理ハンドラ
    ///   - notfoundHandler: 該当商品が見つからない場合の処理ハンドラ
    ///   - errorHadler: 例外処理（ネットワークエラーなど）の処理ハンドラ
    static func searchItem(_ item: String, successHandler: @escaping (PartsInfo) -> Void, notfoundHandler: @escaping (FailureResult) -> Void, errorHadler: @escaping (Error) -> Void) {
        let searchURL = URL(string: "https://akizuki-api.appspot.com/component")!.appendingPathComponent(item)
        
        AF.request(searchURL).responseData { result in
            if let error = result.error {
                DispatchQueue.main.async {
                    errorHadler(error)
                }
                
                return
            }
            
            switch result.result {
            case .failure(let error):
                // タイムアウトなど
                DispatchQueue.main.async {
                    errorHadler(error)
                    return
                }
                
            case .success:
                switch result.response!.statusCode {
                case 200...299:
                    do {
                        let parts = try JSONDecoder().decode(PartsInfo.self, from: result.data!)
                        
                        DispatchQueue.main.async {
                            successHandler(parts)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            errorHadler(error)
                        }
                    }
                    
                case 400...499:
                    do {
                        let fail = try JSONDecoder().decode(FailureResult.self, from: result.data!)
                        
                        DispatchQueue.main.async {
                            notfoundHandler(fail)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            errorHadler(error)
                        }
                    }
                    
                default:
                    fatalError()
                }
            }
        }
    }
    
    /// 指定されたアイテム番号で商品を検索する
    /// - Parameters:
    ///   - items: ^[MKPBRSICT]-[0-9]{5}$.json 形式のアイテム番号で構成された商品名の配列
    ///   - successHandler: 検索成功時の処理ハンドラ
    ///   - notfoundHandler: 該当商品が見つからない場合の処理ハンドラ
    ///   - errorHadler: 例外処理（ネットワークエラーなど）の処理ハンドラ
    static func searchItems(_ items: [String], successHandler: @escaping (Components) -> Void, notfoundHandler: @escaping (FailureResult) -> Void, errorHadler: @escaping (Error) -> Void) {
        // FIXME: 現状だと、items 内に不正なIDがあったとしても、respose の components 内に　2つの型が混在して返還される。
        // 当面の対策として、成功時とエラー時に戻されるキー両方を盛り込んだ Struct を作り、それで強引に一致させて返す
        // TODO: 根本的には、components キーに含まれる型に合わせて処理を切り分ける必要があるが、decoder でうまく切り分けが進まないので、今後の課題とする
        // 大枠として components を取得し、その中で振り分けながら処理させる必要があるかもしれない。
        // - compoments 内の全ての要素に対して
        // -- 200 だったら PartsInfo を取得して、対応する配列に入れる
        // -- それ以外であれば、エラー用の配列に入れる
        
        let searchURL = URL(string: "https://akizuki-api.appspot.com/component/list.json")!
        
        let parameters = ["ids": items]

        AF.request(searchURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
            .responseData { result in
                if let error = result.error {
                    DispatchQueue.main.async {
                        errorHadler(error)
                        
                        return
                    }
                }
                
                switch result.result {
                case .failure(let error):
                    // タイムアウトなど
                    DispatchQueue.main.async {
                        errorHadler(error)
                        return
                    }
                    
                case .success:
                    print("Code:", result.response!.statusCode)
                    switch result.response!.statusCode {
                    case 200...299:
                        do {
                            let components = try JSONDecoder().decode(Components.self, from: result.data!)
                                                        
                            DispatchQueue.main.async {
                                successHandler(components)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                errorHadler(error)
                            }
                        }
                        
                    case 400...499:
                        do {
                            let fail = try JSONDecoder().decode(FailureResult.self, from: result.data!)
                            DispatchQueue.main.async {
                                notfoundHandler(fail)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                errorHadler(error)
                            }
                        }
                        
                    default:
                        fatalError()
                    }
                }
            }
    }
    
    // RxSwiftでリファクタリング
    // ダウンロードの内部状態
    private var downloadState: PublishSubject<DownloadState>
    
    // 外部に見せるダウンロード状態
    var downloadStateObservable: Observable<DownloadState> {
        return downloadState.asObservable()
    }
    
    init() {
        downloadState = PublishSubject<DownloadState>()
    }
    
    /// 指定されたアイテム番号で商品を検索する
    /// - Parameters:
    ///   - item: ^[MKPBRSICT]-[0-9]{5}$.json 形式のアイテム番号
    func fetchItem(_ item: String) {
        let searchURL = URL(string: "https://akizuki-api.appspot.com/component")!.appendingPathComponent(item)
        
        // ダウンロード開始
        downloadState.onNext(.loading)
        
        AF.request(searchURL).responseData { result in
            if let error = result.error {
                self.downloadState.onError(error)
                
                return
            }
            
            switch result.result {
            case .failure(let error):
                // タイムアウトなど
                self.downloadState.onError(error)
                return
                
            case .success:
                switch result.response!.statusCode {
                case 200...299:
                    do {
                        let parts = try JSONDecoder().decode(PartsInfo.self, from: result.data!)
                        
                        // ダウンロードされたパーツ情報を流す
                        self.downloadState.onNext(.finish(parts))
                        self.downloadState.onCompleted()
                        
                    } catch {
                        // デコード失敗
                        self.downloadState.onError(error)
                    }
                    
                case 400...499:
                    do {
                        let fail = try JSONDecoder().decode(FailureResult.self, from: result.data!)
                        
                        // 400系エラーに関する情報を流す
                        self.downloadState.onNext(.failure(fail))
                        self.downloadState.onCompleted()
                    } catch {
                        // デコード失敗
                        self.downloadState.onError(error)
                    }
                    
                default:
                    fatalError()
                }
            }
        }
    }
    
}
