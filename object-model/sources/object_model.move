module object_model_addr::object_model {
 use std::signer;
  use std::string::{Self, String};
  use aptos_framework::object::{Self, Object, ObjectCore, ConstructorRef, TransferRef, ExtendRef, DeleteRef};
  use aptos_framework::fungible_asset::{Metadata};
  use aptos_framework::create_signer::create_signer;
  use aptos_framework::primary_fungible_store;

  struct MyStruct1 has key {
    message: String,
  }
  
  struct MyStruct2 has key {
    message: String,
  }

  struct Refs has key, store, drop {
    extend_ref: ExtendRef,
    transfer_ref: TransferRef,
    delete_ref: DeleteRef,
  }

  entry fun create_object(caller: &signer) {
    // Create object
    let caller_address = signer::address_of(caller);
    let constructor_ref = object::create_object(caller_address);
    let extend_ref = object::generate_extend_ref(&constructor_ref);
    let transfer_ref = object::generate_transfer_ref(&constructor_ref);
    let delete_ref = object::generate_delete_ref(&constructor_ref);

    let object_signer = object::generate_signer(&constructor_ref);
    let object_signerExtend = object::generate_signer_for_extending(&extend_ref);
    
    // Set up the object by creating 2 resources in it
    move_to(&object_signer, MyStruct1 {
      message: string::utf8(b"hello")
    });
    
    move_to(&object_signerExtend, MyStruct2 {
      message: string::utf8(b"world")
    });

    move_to(&object_signerExtend, Refs {
      extend_ref: extend_ref,
      transfer_ref: transfer_ref,
      delete_ref: delete_ref,
    });
  }

  entry fun create_named_object(creator: &signer) {
    let constructor_ref = object::create_named_object(creator, b"SEED");
    
    let extend_ref = object::generate_extend_ref(&constructor_ref);
    let transfer_ref = object::generate_transfer_ref(&constructor_ref);
    let delete_ref = object::generate_delete_ref(&constructor_ref);

    let object_signer = object::generate_signer(&constructor_ref);
    let object_signerExtend = object::generate_signer_for_extending(&extend_ref);
    
    // Set up the object by creating 2 resources in it
    move_to(&object_signer, MyStruct1 {
      message: string::utf8(b"hello")
    });

    move_to(&object_signerExtend, MyStruct2 {
      message: string::utf8(b"world")
    });

    move_to(&object_signerExtend, Refs {
      extend_ref: extend_ref,
      transfer_ref: transfer_ref,
      delete_ref: delete_ref,
    });
  }

  entry fun transfer_object(caller: &signer, object_addr: address, destination: address) {
    let caller_address = signer::address_of(caller);
    let obj = object::address_to_object<ObjectCore>(object_addr);
    
    object::transfer(caller, obj, destination);
  }

  entry fun other(caller: &signer, object_address: address, fa_metadata_address: Object<Metadata>, caller_address: address) acquires Refs {
    let refs = borrow_global<Refs>(object_address);

    let object_signerExtend = object::generate_signer_for_extending(&refs.extend_ref);

    std::debug::print(&object_signerExtend);
    let amount = 100;
    primary_fungible_store::transfer<Metadata>(&object_signerExtend, fa_metadata_address, caller_address, amount);
  }


  #[test(
    admin=@0x6a869af4da6f18f4fd87c610746868da66eb6e961ee69527cec6bee8356408a3,
    user0=@0xd77a195a1691a990b3450f1f9cbe53a52e36a4dd6b8a10fcd8203a948296aa49
  )]
  fun test_create_object_name(admin: signer, user0: address)  {
    std::debug::print(&admin);
    std::debug::print(&user0);

    let a = object::create_named_object(&admin,  b"MyAwesomeObject");
    std::debug::print(&a);

    let admin_address = signer::address_of(&admin);
    std::debug::print(&admin_address);


    let caller_address = signer::address_of(&admin);
    let b = object::create_object(caller_address);
    std::debug::print(&caller_address);
    std::debug::print(&b);

    std::debug::print(&object::generate_signer(&a));
    std::debug::print(&object::generate_signer(&b));


    let object = object::object_from_constructor_ref<ObjectCore>(
      &a
    );
    // std::debug::print(&object);
    // std::debug::print(&object.inner);
    // borrow_global<ObjectCore>(object.inner);
    // std::debug::print(object::owner<MyStruct1>(object));
    // std::debug::print(object::owner(&b));
  }

  #[test(
    admin=@0x6a869af4da6f18f4fd87c610746868da66eb6e961ee69527cec6bee8356408a3,
    user0=@0xd77a195a1691a990b3450f1f9cbe53a52e36a4dd6b8a10fcd8203a948296aa49
  )]
  fun test_resource(admin: signer, user0: address) acquires MyStruct1{
    move_to<MyStruct1>(&admin, MyStruct1 {
      message: string::utf8(b"world")
    });

    let admin_address = signer::address_of(&admin);
    let a = borrow_global_mut<MyStruct1>(admin_address);
    std::debug::print(&a.message);
   
    a.message = string::utf8(b"hello");

    let b = borrow_global_mut<MyStruct1>(admin_address);
    std::debug::print(&b.message);
  }
}