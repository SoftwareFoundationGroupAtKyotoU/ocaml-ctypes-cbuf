module C(F: Ctypes.FOREIGN) = struct
  module IP = struct
    let ip_addr_pton = 
      F.(foreign "ip_addr_pton" (Ctypes.string @-> Ctypes.buffer 4 @-> returning Ctypes.int))
  end

  let int_as_buffer =
    F.(foreign "int_as_buffer" (Ctypes.ptr Ctypes.int @-> returning Ctypes.int))
end
