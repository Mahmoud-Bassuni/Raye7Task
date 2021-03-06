//
//  RepositoryVM.swift
//  Raye7Task
//
//  Created by Bassuni on 5/28/19.
//  Copyright © 2019 Bassuni. All rights reserved.
//

import Foundation
protocol RepositoryVMDelegate : BaseProtocol
{
    func dataBind()
}

class RepositoriesVM
{
    var delegate : RepositoryVMDelegate?
    var Repositories : RepositoriesCodableModel = []
    init(_page : Int) {
        getRepositories(page: _page)
    }
    func getRepositories(page : Int)
    {
        delegate?.showLoading()
        NetworkAdapter.request(target: .getAllRepositories(page: page), success: { [unowned self] Response in
            do
            {
                let decoder = JSONDecoder()
                let getData = try decoder.decode(RepositoriesCodableModel.self,from: Response.data)
                DispatchQueue.global(qos: .background).async {
                    for item in getData
                    {
                        self.Repositories.append(item)
                    }
                    DispatchQueue.main.async {
                        self.delegate?.dataBind()
                    }
                }
            }
            catch let err { print("Err", err)}
            }, error: { Error in
                self.delegate?.showAlert(messgae: Error.localizedDescription)
        }) { MoyaError in
            self.delegate?.showAlert(messgae: MoyaError.localizedDescription)
        }
    }
    deinit {
        Repositories = []
    }
}
extension RepositoriesVM {
    var numberOfSections: Int {
        return 1
    }
    func numberOfRowsInSection(_ section: Int) -> Int {
        return self.Repositories.count
    }

    func articleAtIndex(_ index: Int) -> RepositoryVM {
        let repository = Repositories[index]
        return RepositoryVM(repository)
    }

}
struct RepositoryVM {
    private let repository: RepositoryElement
    init(_ repository: RepositoryElement) {
        self.repository = repository
    }
}
extension RepositoryVM {
    var name: String {
        return self.repository.name
    }
    var description: String {
        return self.repository.reposCodableModelDescription
    }
    var forksCount: Int {
        return self.repository.forksCount
    }
    var language: String {
        return self.repository.language
    }
    var createdAt: String {
        return self.repository.createdAt
    }
    var htmlURL: String {
        return self.repository.htmlURL
    }
    var photo: String {
        return self.repository.owner == nil ? "" :  self.repository.owner.avatarURL
    }
}

