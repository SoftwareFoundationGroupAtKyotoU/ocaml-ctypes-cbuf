module C(F: Ctypes.FOREIGN) = struct
  module IP = struct
    let ip_addr_pton = 
      F.(foreign "ip_addr_pton" (Ctypes.string @-> Ctypes.ocaml_bytes @-> returning Ctypes.int))
  end
end
