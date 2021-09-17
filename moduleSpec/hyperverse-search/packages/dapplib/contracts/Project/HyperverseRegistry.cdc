pub contract HyperverseRegistry {

  pub event RecordsNotFound()
  pub event Registered()

  pub struct Record {
    pub let title: String
    pub let account: Address
    pub let contracts: [String]
    pub let external: String

    init(
      title: String,
      account: Address,
      contracts: [String],
      external: String
    ) {
      self.title = title
      self.account = account
      self.contracts = contracts
      self.external = external
    }
  }

  pub let RecordsStoragePath: StoragePath

  init() {
    let records: [Record] = []

    self.RecordsStoragePath = /storage/HyperverseRegistryRecords

    self.account.save<[Record]>(records, to: self.RecordsStoragePath)
  }

  pub fun register(
    title: String,
    account: Address,
    contracts: [String],
    external: String
  ) {
    let record = Record(title: title, account: account, contracts: contracts, external: external)
    let records = self.account.load<[Record]>(from: self.RecordsStoragePath)

    if records != nil {
      records!.append(record)
      self.account.save(records!, to: self.RecordsStoragePath)

      emit Registered()
    } else {
      emit RecordsNotFound()
    }
  }

  pub fun getRecords(): [Record]? {
    let records = self.account.copy<[Record]>(from: self.RecordsStoragePath)
    if records != nil {
      return records
    } else {
      return nil
    }
  }
}