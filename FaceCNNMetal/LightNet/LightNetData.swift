// Copyright 2016 Sudev Bohra All rights reserved.
//
// Created by Sudev Bohra on 12/10/16.
//
// Not for commercial use.

import Foundation

/*
  Encapsulates access to the weights that are stored in parameters.data.
  
  We only need to read from the parameters file while the neural network is
  being created. The weights are copied into the network (as 16-bit floats),
  so once the network is set up we no longer need to keep parameters.data
  in memory.

  Because this is a huge file, we use mmap() so that not the entire file has
  to be read into memory at once. Deallocating LightNetData unmaps the file.
*/
class LightNetData {
  // Size of the data file in bytes.
  let fileSize = 124611404

  // These are the offsets in the big blob of data of the weights and biases
  // for each layer. (This code was generated by the convert_LightNet.py script.)

  var conv1_w: UnsafeMutablePointer<Float> { return ptr + 0 }
  var conv1_b: UnsafeMutablePointer<Float> { return ptr + 2400 }
  var conv2a_w: UnsafeMutablePointer<Float> { return ptr + 2496 }
  var conv2a_b: UnsafeMutablePointer<Float> { return ptr + 7104 }
  var conv2_w: UnsafeMutablePointer<Float> { return ptr + 7200 }
  var conv2_b: UnsafeMutablePointer<Float> { return ptr + 90144 }
  var conv3a_w: UnsafeMutablePointer<Float> { return ptr + 90336 }
  var conv3a_b: UnsafeMutablePointer<Float> { return ptr + 108768 }
  var conv3_w: UnsafeMutablePointer<Float> { return ptr + 108960 }
  var conv3_b: UnsafeMutablePointer<Float> { return ptr + 440736 }
  var conv4a_w: UnsafeMutablePointer<Float> { return ptr + 441120 }
  var conv4a_b: UnsafeMutablePointer<Float> { return ptr + 514848 }
  var conv4_w: UnsafeMutablePointer<Float> { return ptr + 515232 }
  var conv4_b: UnsafeMutablePointer<Float> { return ptr + 957600 }
  var conv5a_w: UnsafeMutablePointer<Float> { return ptr + 957856 }
  var conv5a_b: UnsafeMutablePointer<Float> { return ptr + 990624 }
  var conv5_w: UnsafeMutablePointer<Float> { return ptr + 990880 }
  var conv5_b: UnsafeMutablePointer<Float> { return ptr + 1285792 }
  var fc1_w: UnsafeMutablePointer<Float> { return ptr + 1286048 }
  var fc1_b: UnsafeMutablePointer<Float> { return ptr + 5480352 }
  var fc2_ms_w: UnsafeMutablePointer<Float> { return ptr + 5480864 }
  var fc2_ms_b: UnsafeMutablePointer<Float> { return ptr + 31052960 }

  private var fd: CInt!
  private var hdr: UnsafeMutableRawPointer!
  private var ptr: UnsafeMutablePointer<Float>!

  /* This is for debugging. Initializing the weights to 0 gives an output of
     0.000999451, or approx 1/1000 for all classes, which is what you'd expect
     for a softmax classifier. */
  init() {
    let numBytes = fileSize / MemoryLayout<Float>.size
    ptr = UnsafeMutablePointer<Float>.allocate(capacity: numBytes)
    ptr.initialize(to: 0, count: numBytes)
  }

  init?(path: String) {
    fd = open(path, O_RDONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)
    if fd == -1 {
      print("Error: failed to open \"\(path)\", error = \(errno)")
      return nil
    }

    hdr = mmap(nil, fileSize, PROT_READ, MAP_FILE | MAP_SHARED, fd, 0)
    if hdr == nil {
      print("Error: mmap failed, errno = \(errno)")
      return nil
    }

    let numBytes = fileSize / MemoryLayout<Float>.size
    ptr = hdr.bindMemory(to: Float.self, capacity: numBytes)
    if ptr == UnsafeMutablePointer<Float>(bitPattern: -1) {
      print("Error: mmap failed, errno = \(errno)")
      return nil
    }
  }

  deinit{
    print("deinit \(self)")

    if let hdr = hdr {
      let result = munmap(hdr, Int(fileSize))
      assert(result == 0, "Error: munmap failed, errno = \(errno)")
    }
    if let fd = fd {
      close(fd)
    }
  }
}