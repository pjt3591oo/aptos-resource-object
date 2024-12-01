module resource_model_addr::resource_model {
  use std::signer;
  use std::string;

  #[resource_group(scope = global)]
  struct MyResourceGroup {}

  #[resource_group_member(group = MyResourceGroup)]
  struct Counter has key {
      value: u64,
  }

  #[resource_group_member(group = MyResourceGroup)]
  struct Name has key {
    name: string::String,
  }

  entry public fun initialize(account: &signer) {
    let _addr = signer::address_of(account);
    
    move_to(account, Counter { value: 0 });
    move_to(account, Name { name: string::utf8(b"Alice") });
  }

  entry public fun increment(account: &signer) acquires Counter {
    let counter = borrow_global_mut<Counter>(signer::address_of(account));
    let counter1 = counter;
    counter.value = counter.value + 1;
  }
}