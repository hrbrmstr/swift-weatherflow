import Foundation

func htons(value: Int) -> CUnsignedShort {
  return (CUnsignedShort(value) << 8) + (CUnsignedShort(value) >> 8)
}

var si_me = sockaddr_in()
var si_other = sockaddr_in()
var port = 50222
var broadcast = 1

var s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)

setsockopt(s,  SOL_SOCKET, SO_BROADCAST, &broadcast, UInt32(MemoryLayout.size(ofValue: broadcast)))

memset(&si_me, 0, MemoryLayout.size(ofValue: si_me))

si_me.sin_family = UInt8(AF_INET)
si_me.sin_port = htons(value: port)
si_me.sin_addr.s_addr = INADDR_ANY

withUnsafePointer(to: &si_me) { sockaddrInPtr in
  let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
  bind(s, sockaddrPtr, UInt32(MemoryLayout<sockaddr_in>.stride))
}

var buffer = [CChar](repeating: 0, count: 1024)
var slen = socklen_t(MemoryLayout.size(ofValue: si_other))

repeat {
  
  let len = withUnsafeMutablePointer(to: &si_other) {
    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
      recvfrom(s, &buffer, buffer.count, 0, $0, &slen)
    }
  }
  
  let res: String = String(bytesNoCopy: &buffer, length: len, encoding: .utf8, freeWhenDone: false)!
  
  print("\(res)")
  
} while(true)


