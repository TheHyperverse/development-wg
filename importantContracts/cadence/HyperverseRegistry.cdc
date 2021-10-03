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
    let records: {Address: Record} = {}

    self.RecordsStoragePath = /storage/HyperverseRegistryRecords

    self.account.save<{Address: Record}>(records, to: self.RecordsStoragePath)
  }

  pub fun register(
    title: String,
    account: Address,
    contracts: [String],
    external: String
  ) {
    let record = Record(title: title, account: account, contracts: contracts, external: external)
    let records = self.account.load<{Address: Record}>(from: self.RecordsStoragePath)
                    ?? panic("Could now load the Records from account storage")

    if records != nil {
      records[account] = record
      self.account.save(records, to: self.RecordsStoragePath)

      emit Registered()
    } else {
      emit RecordsNotFound()
    }
  }

  pub fun getRecords(): {Address: Record}? {
    let records = self.account.copy<{Address: Record}>(from: self.RecordsStoragePath)
    if records != nil {
      return records
    } else {
      return nil
    }
  }

  pub fun getRecord(address: Address, contract: String): Record? {
    let records = self.account.load<{Address: Record}>(from: self.RecordsStoragePath)
                      ?? panic("Could now load the Records from account storage")
    return records[address]
  }
}