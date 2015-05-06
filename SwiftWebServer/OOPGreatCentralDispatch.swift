//
//  OOPGreatCentralDispatch.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/12/21.
//  Copyright (c) 2014 nagata_kobo. All rights reserved.
//

import Foundation
import Dispatch

public class OOPDispatchObject {
    private var dispatch_object: dispatch_object_t!
    
    private init() {
    }
    
    private init(_ dispatch_object: dispatch_object_t) {
        self.dispatch_object = dispatch_object
    }
}

public class OOPDispatchQueueAttr: OOPDispatchObject {
    private var queue_attr: dispatch_queue_attr_t {
        return self.dispatch_object as dispatch_queue_attr_t
    }
    
    public class var Cuncurrent: OOPDispatchQueueAttr {
        return OOPDispatchQueueAttr(DISPATCH_QUEUE_CONCURRENT)
    }
    
    public class var Serial: OOPDispatchQueueAttr {
        return OOPDispatchQueueAttr(DISPATCH_QUEUE_SERIAL)
    }
    
    ///dispatch_queue_attr_make_with_qos_class
    ///Returns attributes suitable for creating a dispatch queue with the desired quality-of-service information.
    public class func make(attr: OOPDispatchQueueAttr, qosClass: OOPDispatchQoSClass, relativePriority: Int) -> OOPDispatchQueueAttr {
        let queue_attr = dispatch_queue_attr_make_with_qos_class(attr.queue_attr, qosClass.qos_class, Int32(relativePriority))
        return OOPDispatchQueueAttr(queue_attr)
    }
}

public struct OOPDispatchQoSClass {
    private var qos_class: dispatch_qos_class_t
    
    //QOS_CLASS_USER_INTERACTIVE, QOS_CLASS_USER_INITIATED, QOS_CLASS_UTILITY, or QOS_CLASS_BACKGROUND.
    public static let UserInteractive = OOPDispatchQoSClass(qos_class: QOS_CLASS_USER_INTERACTIVE)
    public static let UserInitiated = OOPDispatchQoSClass(qos_class: QOS_CLASS_USER_INITIATED)
    public static let Utility = OOPDispatchQoSClass(qos_class: QOS_CLASS_UTILITY)
    public static let Background = OOPDispatchQoSClass(qos_class: QOS_CLASS_BACKGROUND)
}

public class OOPDispatchQueue: OOPDispatchObject {
    private var dispatch_queue: dispatch_queue_t {
        return dispatch_object as dispatch_queue_t
    }
    
    private override init(_ dispatch_queue: dispatch_queue_t) {
        super.init(dispatch_queue as dispatch_object_t)
    }
    
    ///dispatch_get_main_queue
    ///Returns the serial dispatch queue associated with the application’s main thread.
    public class var mainQueue: OOPDispatchQueue {
        struct My {
            static var mainQueue: OOPDispatchQueue = OOPDispatchQueue(dispatch_get_main_queue())
        }
        return My.mainQueue
    }
    
    ///dispatch_get_global_queue
    ///Returns a system-defined global concurrent queue with the specified quality of service class.
    public class func getGlobalQueue(identifier: Int, flags: UInt) -> OOPDispatchQueue {
        return OOPDispatchQueue(dispatch_get_global_queue(identifier, flags))
    }
    
    ///dispatch_queue_create
    ///Creates a new dispatch queue to which blocks can be submitted.
    public convenience init(label: String, attr: OOPDispatchQueueAttr) {
        let queue = dispatch_queue_create(label, attr.queue_attr)
        self.init(queue)
    }
    
    ///dispatch_queue_get_label
    ///Returns the label specified for the queue when the queue was created.
    public private(set)
    lazy var label: String = String.fromCString(dispatch_queue_get_label(self.dispatch_queue))!
    
    ///dispatch_set_target_queue
    ///Sets the target queue for the given object.
    public func setTargetQueue(target: OOPDispatchQueue) {
        dispatch_set_target_queue(self.dispatch_queue, target.dispatch_queue)
    }

    ///dispatch_main
    ///Executes blocks submitted to the main queue.
    public class func executeMain() {
        dispatch_main()
    }
}

//MARK: -
//MARK: Queuing Tasks for Dispatch
public extension OOPDispatchQueue {
    ///dispatch_async
    ///Submits a block for asynchronous execution on a dispatch queue and returns immediately.
    public func async(block: dispatch_block_t) {
        dispatch_async(self.dispatch_queue, block)
    }

    ///dispatch_sync
    ///Submits a block object for execution on a dispatch queue and waits until that block completes.
    public func sync(block: dispatch_block_t) {
        dispatch_sync(self.dispatch_queue, block)
    }

    ///dispatch_after
    ///Enqueue a block for execution at the specified time.
    public func after(when: OOPDispatchTime, block: dispatch_block_t) {
        dispatch_after(when.time, self.dispatch_queue, block)
    }

    ///dispatch_apply
    ///Submits a block to a dispatch queue for multiple invocations.
    public func apply(iterations: Int, block: Int->Void) {
        assert(iterations >= 0)
        dispatch_apply(iterations, self.dispatch_queue, {iter in block(iter)})
    }

    ///dispatch_once
    ///Executes a block object once and only once for the lifetime of an application.
    public func once(predicate: UnsafeMutablePointer<dispatch_once_t>, block: dispatch_block_t) {
        dispatch_once(predicate, block)
    }

}

//MARK: -
//MARK: Using Dispatch Groups
public class OOPDispatchGroup: OOPDispatchObject {
    private var dispatch_group: dispatch_group_t {
        return self.dispatch_object as dispatch_group_t
    }
    
    private override init(_ dispatch_group: dispatch_group_t) {
        super.init(dispatch_group as dispatch_object_t)
    }
    
    ///dispatch_group_async
    ///Submits a block to a dispatch queue and associates the block with the specified dispatch group.
    public func async(queue: OOPDispatchQueue, block: dispatch_block_t) {
        dispatch_group_async(self.dispatch_group, queue.dispatch_queue, block)
    }

    ///dispatch_group_create
    ///Creates a new group with which block objects can be associated.
    public convenience override init() {
        self.init(dispatch_group_create())
    }

    ///dispatch_group_enter
    ///Explicitly indicates that a block has entered the group.
    public func enter() {
        dispatch_group_enter(self.dispatch_group)
    }

    ///dispatch_group_leave
    ///Explicitly indicates that a block in the group has completed.
    public func leave() {
        dispatch_group_leave(self.dispatch_group)
    }

    ///dispatch_group_notify
    ///Schedules a block object to be submitted to a queue when a group of previously submitted block objects have completed.
    public func notify(queue: OOPDispatchQueue, block: dispatch_block_t) {
        dispatch_group_notify(self.dispatch_group, queue.dispatch_queue, block)
    }

    ///dispatch_group_wait
    ///Waits synchronously for the previously submitted block objects to complete; returns if the blocks do not complete before the specified timeout period has elapsed.
    public func wait(timeout: OOPDispatchTime) -> Int {
        return dispatch_group_wait(self.dispatch_group, timeout.time)
    }

}

//MARK: -
//MARK: Managing Dispatch Objects
extension OOPDispatchObject {
    ///dispatch_get_context
    ///Returns the application-defined context of an object.
    public var context: UnsafeMutablePointer<Void> {
        get {
            return dispatch_get_context(self.dispatch_object)
        }
        ///dispatch_set_context
        ///Associates an application-defined context with the object.
        set {
            assert(newValue != nil)
            dispatch_set_context(self.dispatch_object, newValue)
        }
    }

    ///dispatch_resume
    ///Resume the invocation of block objects on a dispatch object.
    public func resume() {
        dispatch_resume(self.dispatch_object)
    }

    ///dispatch_suspend
    ///Suspends the invocation of block objects on a dispatch object.
    public func suspend() {
        dispatch_suspend(self.dispatch_object)
    }
}

//MARK: -
//MARK: Using Semaphores
public class OOPDispatchSemaphore: OOPDispatchObject {
    private var dispatch_semaphore: dispatch_semaphore_t {
        return self.dispatch_object as dispatch_semaphore_t
    }
    
    private override init(_ dispatch_semaphore: dispatch_semaphore_t) {
        super.init(dispatch_semaphore as dispatch_object_t)
    }
    
    ///dispatch_semaphore_create
    ///Creates new counting semaphore with an initial value.
    public convenience init(value: Int) {
        let dispatch_semaphore = dispatch_semaphore_create(value)
        self.init(dispatch_semaphore)
    }

    ///dispatch_semaphore_signal
    ///Signals (increments) a semaphore.
    public func signal() -> Int {
        return dispatch_semaphore_signal(self.dispatch_semaphore)
    }

    ///dispatch_semaphore_wait
    ///Waits for (decrements) a semaphore.
    public func wait(timeout: OOPDispatchTime) -> Int {
        return dispatch_semaphore_wait(self.dispatch_semaphore, timeout.time)
    }

}

//MARK: -
//MARK: Using Barriers
extension OOPDispatchQueue {
    
    ///dispatch_barrier_async
    ///Submits a barrier block for asynchronous execution and returns immediately.
    public func barrierAsync(block: dispatch_block_t) {
        dispatch_barrier_async(self.dispatch_queue, block)
    }

    ///dispatch_barrier_sync
    ///Submits a barrier block object for execution and waits until that block completes.
    public func barrierSync(block: dispatch_block_t) {
        dispatch_barrier_sync(self.dispatch_queue, block)
    }

}

//MARK: -
//MARK: Managing Dispatch Sources
public class OOPDispatchSource: OOPDispatchObject {
    private var dispatch_source: dispatch_source_t {
        return self.dispatch_object as dispatch_source_t
    }
    private class var dispatch_source_type: dispatch_source_type_t! {
        return nil  //indicating abstract type
    }

    public required init?(handle: UInt, mask: UInt, queue: OOPDispatchQueue) {
        super.init()
        let source_type = self.dynamicType.dispatch_source_type
        assert(source_type != nil)
        if let dispatch_source = dispatch_source_create(source_type, handle, mask, queue.dispatch_queue) {
            self.dispatch_object = dispatch_source as dispatch_object_t
        } else {
            return nil
        }
    }
    
    ///dispatch_source_cancel
    ///Asynchronously cancels the dispatch source, preventing any further invocation of its event handler block.
    public func cancel() {
        dispatch_source_cancel(self.dispatch_source)
    }

    private var rawData: UInt {
        return dispatch_source_get_data(self.dispatch_source)
    }

    private var rawHandle: UInt {
        return dispatch_source_get_handle(self.dispatch_source)
    }
    
    private var rawMask: UInt {
        return dispatch_source_get_mask(self.dispatch_source)
    }
    
    public class NoArg: OOPDispatchSource {
        public convenience init?(queue: OOPDispatchQueue) {
            self.init(handle: 0, mask: 0, queue: queue)
        }
        
        public var data: UInt {
            return self.rawData
        }
    }
    
    public class DataAdd: NoArg {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_DATA_ADD
        }
        
        ///dispatch_source_merge_data
        //Merges data into a dispatch source of type DISPATCH_SOURCE_TYPE_DATA_ADD or DISPATCH_SOURCE_TYPE_DATA_OR and submits its event handler block to its target queue.
        public func mergeData(data: UInt) {
            dispatch_source_merge_data(self.dispatch_source, data)
        }
    }
    public class Timer: NoArg {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_TIMER
        }
    }
    
    public class DataOr: OOPDispatchSource {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_DATA_OR
        }
        
        public convenience init?(mask: UInt, queue: OOPDispatchQueue) {
            self.init(handle: 0, mask: mask, queue: queue)
        }
        
        public var data: UInt {
            return self.rawData
        }

        ///dispatch_source_merge_data
        //Merges data into a dispatch source of type DISPATCH_SOURCE_TYPE_DATA_ADD or DISPATCH_SOURCE_TYPE_DATA_OR and submits its event handler block to its target queue.
        public func mergeData(data: UInt) {
            dispatch_source_merge_data(self.dispatch_source, data)
        }
    }
    
    public class MachRecv: OOPDispatchSource {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_MACH_RECV
        }
        
        public convenience init?(handle: mach_port_t, queue: OOPDispatchQueue) {
            self.init(handle: UInt(handle), mask: 0, queue: queue)
        }
        
        public var handle: mach_port_t {
            return mach_port_t(self.rawHandle)
        }
    }
    
    public class MachSend: OOPDispatchSource {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_MACH_SEND
        }
        
        public convenience init?(handle: mach_port_t, mask: dispatch_source_mach_send_flags_t, queue: OOPDispatchQueue) {
            self.init(handle: UInt(handle), mask: mask, queue: queue)
        }
        
        public var data: dispatch_source_mach_send_flags_t {
            return self.rawData
        }
        
        public var handle: mach_port_t {
            return mach_port_t(self.rawHandle)
        }
        
        public var mask: dispatch_source_mach_send_flags_t {
            return self.rawMask
        }
    }
    
    public class Proc: OOPDispatchSource {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_PROC
        }
        
        public convenience init?(handle: pid_t, mask: dispatch_source_proc_flags_t, queue: OOPDispatchQueue) {
            self.init(handle: UInt(handle), mask: UInt(mask), queue: queue)
        }
        
        public var data: dispatch_source_proc_flags_t {
            return self.rawData
        }
        
        public var handle: pid_t {
            return pid_t(self.rawHandle)
        }
        
        public var mask: dispatch_source_proc_flags_t {
            return self.rawMask
        }
    }
    
    public class CIntHandle: OOPDispatchSource {
        
        public convenience init?(handle: CInt, queue: OOPDispatchQueue) {
            self.init(handle: UInt(handle), mask: 0, queue: queue)
        }
        
        public var data: UInt {
            return self.rawData
        }
        
        public var handle: CInt {
            return Int32(self.rawHandle)
        }
    }
    
    public class Read: CIntHandle {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_READ
        }
        
    }
    
    public class Write: CIntHandle {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_WRITE
        }
        
    }
    
    public class Signal: CIntHandle {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_SIGNAL
        }
        
    }
    
    public class MemorypressureFlags: OOPDispatchSource {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_MEMORYPRESSURE
        }
        
        public convenience init?(mask: dispatch_source_memorypressure_flags_t, queue: OOPDispatchQueue) {
            self.init(handle: 0, mask: UInt(mask), queue: queue)
        }
        
        public var mask: dispatch_source_memorypressure_flags_t {
            return self.rawMask
        }
    }
    
    public class Vnode: OOPDispatchSource {
        private override class var dispatch_source_type: dispatch_source_type_t {
            return DISPATCH_SOURCE_TYPE_VNODE
        }
        
        public convenience init?(handle: CInt, mask: dispatch_source_vnode_flags_t, queue: OOPDispatchQueue) {
            self.init(handle: UInt(handle), mask: UInt(mask), queue: queue)
        }
        
        public var data: dispatch_source_vnode_flags_t {
            return self.rawData
        }
        
        public var handle: CInt {
            return CInt(self.rawHandle)
        }
        
        public var mask: dispatch_source_vnode_flags_t {
            return self.rawMask
        }
    }
    
    ///dispatch_source_create
    ///Creates a new dispatch source to monitor low-level system objects and automatically submit a handler block to a dispatch queue in response to events.
    public class func create<T: OOPDispatchSource>(type: T.Type, handle: UInt, mask: UInt, queue: OOPDispatchQueue) -> T? {
        return T(handle: handle, mask: mask, queue: queue)
    }
    
    ///dispatch_source_set_registration_handler
    ///Sets the registration handler block for the given dispatch source.
    public func setRegistrationHandler(handler: dispatch_block_t) {
        dispatch_source_set_registration_handler(self.dispatch_source, handler)
    }

    ///dispatch_source_set_cancel_handler
    ///Sets the cancellation handler block for the given dispatch source.
    public func setCancelHandler(handler: dispatch_block_t) {
        dispatch_source_set_cancel_handler(self.dispatch_source, handler)
    }

    ///dispatch_source_set_event_handler
    ///Sets the event handler block for the given dispatch source.
    public func setEventHandler(handler: dispatch_block_t) {
        dispatch_source_set_event_handler(self.dispatch_source, handler)
    }

    ///dispatch_source_set_timer
    ///Sets a start time, interval, and leeway value for a timer source.
    public func setTimer(start: OOPDispatchTime, interval: UInt64, leeway: UInt64) {
        dispatch_source_set_timer(self.dispatch_source, start.time, interval, leeway)
    }

    ///dispatch_source_testcancel
    ///Tests whether the given dispatch source has been canceled.
    public var canceled: Bool {
        return dispatch_source_testcancel(self.dispatch_source) != 0
    }

}

//MARK: -
//MARK: Using the Dispatch I/O Convenience API
public struct OOPDispatchFD {
    private var dispatch_fd: dispatch_fd_t
    
    ///dispatch_read
    ///Schedule an asynchronous read operation using the specified file descriptor.
    public func read(length: Int, queue: OOPDispatchQueue, handler: (dispatch_data_t!, Int)->Void) {
        assert(length >= 0)
        dispatch_read(self.dispatch_fd, length, queue.dispatch_queue, {data, err in
            handler(data, Int(err))
        })
    }
    
    ///dispatch_write
    ///Schedule an asynchronous write operation using the specified file descriptor.
    public func write(data: dispatch_data_t, queue: OOPDispatchQueue, handler: (dispatch_data_t!, Int)->Void) {
        dispatch_write(self.dispatch_fd, data, queue.dispatch_queue, {data, err in
            handler(data, Int(err))
        })
    }

}

//MARK: -
//MARK: Using the Dispatch I/O Channel API
public struct OOPDispatchIOType {
    var io_type: dispatch_io_type_t
    
    static var Stream: OOPDispatchIOType {return OOPDispatchIOType(io_type: DISPATCH_IO_STREAM)}
    static var Random: OOPDispatchIOType {return OOPDispatchIOType(io_type: DISPATCH_IO_RANDOM)}
}
public class OOPDispatchIO: OOPDispatchObject {
    private var dispatch_io: dispatch_io_t {
        return self.dispatch_object as dispatch_io_t
    }
    
//    private override init(_ dispatch_io: dispatch_io_t) {
//        super.init(dispatch_io as dispatch_object_t)
//    }
    
    ///dispatch_io_create
    ///Creates a dispatch I/O channel and associates it with the specified file descriptor.
    public init?(type: OOPDispatchIOType, fd: OOPDispatchFD, queue: OOPDispatchQueue, cleanupHandler: (Int -> Void)?) {
        super.init()
        if let dispatch_io = dispatch_io_create(type.io_type, fd.dispatch_fd, queue.dispatch_queue, cleanupHandler != nil ? {err in cleanupHandler!(Int(err))} : nil) {
            self.dispatch_object = dispatch_io as dispatch_object_t
        } else {
            return nil
        }
    }

    ///dispatch_io_create_with_path
    ///Creates a dispatch I/O channel with the associated path name.
    public init?(type: OOPDispatchIOType, path: String, oflag: Int, mode: mode_t, queue: OOPDispatchQueue, cleanupHandler: (Int -> Void)?) {
        super.init()
        if let dispatch_io = dispatch_io_create_with_path(type.io_type, path, Int32(oflag), mode, queue.dispatch_queue, cleanupHandler != nil ? {err in cleanupHandler!(Int(err))} : nil) {
            self.dispatch_object = dispatch_io as dispatch_object_t
        } else {
            return nil
        }
    }

    ///dispatch_io_create_with_io
    //Creates a new dispatch I/O channel from an existing channel.
    public init?(type: OOPDispatchIOType, io: OOPDispatchIO, queue: OOPDispatchQueue, cleanupHandler: (Int -> Void)?) {
        super.init()
        if let dispatch_io = dispatch_io_create_with_io(type.io_type, io.dispatch_io, queue.dispatch_queue, cleanupHandler != nil ? {err in cleanupHandler!(Int(err))} : nil) {
            self.dispatch_object = dispatch_io as dispatch_object_t
        } else {
            return nil
        }
    }
    
    ///dispatch_io_read
    ///Schedules an asynchronous read operation on the specified channel.
    public func read(offset: off_t, length: Int, queue: OOPDispatchQueue, ioHandler: dispatch_io_handler_t) {
        dispatch_io_read(self.dispatch_io, offset, length, queue.dispatch_queue, ioHandler)
    }

    ///dispatch_io_write
    ///Schedules an asynchronous write operation for the specified channel.
    public func write(offset: off_t, data: dispatch_data_t, queue: OOPDispatchQueue, ioHandler: dispatch_io_handler_t) {
        dispatch_io_write(self.dispatch_io, offset, data, queue.dispatch_queue, ioHandler)
    }

    ///dispatch_io_close
    ///Closes the specified channel to new read and write operations.
    public func close(flags: dispatch_io_close_flags_t) {
        dispatch_io_close(self.dispatch_io, flags)
    }

    ///dispatch_io_barrier
    ///Schedules a barrier operation on the specified channel.
    public func barrier(barrier: dispatch_block_t) {
        dispatch_io_barrier(self.dispatch_io, barrier)
    }

    ///dispatch_io_set_high_water
    ///Sets the maximum number of bytes to process before enqueueing a handler block.
    public func setHighWater(highWater: size_t) {
        dispatch_io_set_high_water(self.dispatch_io, highWater)
    }

    ///dispatch_io_set_low_water
    ///Sets the minimum number of bytes to process before enqueueing a handler block.
    public func setLowWater(lowWater: size_t) {
        dispatch_io_set_low_water(self.dispatch_io, lowWater)
    }

    ///dispatch_io_set_interval
    ///Sets the interval (in nanoseconds) at which to invoke the I/O handlers for the channel.
    public func setInterval(interval: UInt64, flags: dispatch_io_interval_flags_t) {
        dispatch_io_set_interval(self.dispatch_io, interval, flags)
    }

    ///dispatch_io_get_descriptor
    ///Returns the file descriptor associated with the specified channel.
    public var descriptor: OOPDispatchFD {
        return OOPDispatchFD(dispatch_fd: dispatch_io_get_descriptor(self.dispatch_io))
    }

}

//MARK: -
//MARK: Managing Dispatch Data Objects
public class OOPDispatchData: OOPDispatchObject {
    private var dispatch_data: dispatch_data_t {
        return self.dispatch_object as dispatch_data_t
    }
    
    private override init(_ dispatch_data: dispatch_data_t) {
        super.init(dispatch_data as dispatch_object_t)
    }

    ///dispatch_data_create
    ///Creates a new dispatch data object with the specified memory buffer.
    public init?(buffer: UnsafePointer<Void>, size: size_t, queue: OOPDispatchQueue, destructor: dispatch_block_t) {
        super.init()
        if let dispatch_data = dispatch_data_create(buffer, size, queue.dispatch_queue, destructor) {
            self.dispatch_object = dispatch_data as dispatch_object_t
        } else {
            return nil
        }
    }
    
    public init?<T>(array: [T], queue: OOPDispatchQueue, destructor: dispatch_block_t) {
        super.init()
        let size = size_t(sizeof(T)) * size_t(array.count)
        if let dispatch_data = dispatch_data_create(array, size, queue.dispatch_queue, destructor) {
            self.dispatch_object = dispatch_data as dispatch_object_t
        } else {
            return nil
        }
    }
    
    ///dispatch_data_get_size
    ///Returns the logical size of the memory managed by a dispatch data object
    public var size: size_t {
        return dispatch_data_get_size(self.dispatch_data)
    }

    ///dispatch_data_create_map
    ///Returns a new dispatch data object containing a contiguous representation of the specified object’s memory.
    func map(bufferPtr: UnsafeMutablePointer<UnsafePointer<Void>>, sizePtr: UnsafeMutablePointer<size_t>) -> OOPDispatchData? {
        if let dispatch_data = dispatch_data_create_map(self.dispatch_data, bufferPtr, sizePtr) {
            return OOPDispatchData(dispatch_data)
        } else {
            return nil
        }
    }

    ///dispatch_data_create_concat
    ///Returns a new dispatch data object consisting of the concatenated data from two other data objects.
    public func concatenated(data: OOPDispatchData) -> OOPDispatchData {
        let dispatch_data = dispatch_data_create_concat(self.dispatch_data, data.dispatch_data)
        return OOPDispatchData(dispatch_data)
    }

    ///dispatch_data_create_subrange
    ///Returns a new dispatch data object whose contents consist of a portion of another object’s memory region.
    public func subrange(offset: size_t, length: size_t) -> OOPDispatchData {
        let dispatch_data = dispatch_data_create_subrange(self.dispatch_data, offset, length)
        return OOPDispatchData(dispatch_data)
    }
    
    ///dispatch_data_apply
    ///Traverses the memory of a dispatch data object and executes custom code on each region.
    public func apply(applier: dispatch_data_applier_t) -> Bool {
        return dispatch_data_apply(self.dispatch_data, applier)
    }

    ///dispatch_data_copy_region
    ///Returns a data object containing a portion of the data in another data object.
    public func copyRegion(location: Int, offsetPtr: UnsafeMutablePointer<Int>) -> OOPDispatchData {
        var offset: Int = 0
        let copied_data = dispatch_data_copy_region(self.dispatch_data, location, &offset)
        if( offsetPtr != nil ) {
            offsetPtr.memory = Int(offset)
        }
        return OOPDispatchData(copied_data)
    }

}
public func +(lhs: OOPDispatchData, rhs:OOPDispatchData) -> OOPDispatchData {
    return lhs.concatenated(rhs)
}

//MARK: -
//MARK: Managing Time
public struct OOPDispatchTime {
    private var time: dispatch_time_t
    
    ///dispatch_time
    ///Creates a dispatch_time_t relative to the default clock or modifies an existing dispatch_time_t.
    public func delta(delta: Int64) -> OOPDispatchTime {
        return OOPDispatchTime(time: dispatch_time(self.time, delta))
    }
    
    public static var Now: OOPDispatchTime {
        return OOPDispatchTime(time: DISPATCH_TIME_NOW)
    }
    
    public static var Forever: OOPDispatchTime {
        return OOPDispatchTime(time: DISPATCH_TIME_FOREVER)
    }
    
    public static func walltime(when: timespec, delta: Int64) -> OOPDispatchTime {
        var ts = when
        return OOPDispatchTime(time: dispatch_walltime(&ts, delta))
    }
    
    public static func walltime(delta: Int64) -> OOPDispatchTime {
        return OOPDispatchTime(time: dispatch_walltime(nil, delta))
    }
}

//MARK: -
//MARK: Managing Queue-Specific Context Data
extension OOPDispatchQueue {
    ///dispatch_queue_set_specific
    ///Sets the key/value data for the specified dispatch queue.
    public func setSpecific(key: UnsafePointer<Void>, context: UnsafeMutablePointer<Void>, destructor: dispatch_function_t) {
        dispatch_queue_set_specific(self.dispatch_queue, key, context, destructor)
    }
    
    ///dispatch_queue_get_specific
    ///Gets the value for the key associated with the specified dispatch queue.
    public func getSpecific(key: UnsafePointer<Void>) -> UnsafeMutablePointer<Void> {
        return dispatch_queue_get_specific(self.dispatch_queue, key)
    }

    ///dispatch_get_specific
    ///Returns the value for the key associated with the current dispatch queue.
    public class func getSpecific(key: UnsafeMutablePointer<Void>) ->UnsafeMutablePointer<Void> {
        return dispatch_get_specific(key)
    }
}