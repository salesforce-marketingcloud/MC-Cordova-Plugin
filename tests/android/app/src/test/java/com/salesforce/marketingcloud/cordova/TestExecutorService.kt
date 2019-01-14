/**
 * Copyright 2018 Salesforce, Inc
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.salesforce.marketingcloud.cordova

import java.util.concurrent.Callable
import java.util.concurrent.ExecutorService
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit

class TestExecutorService : ExecutorService {
    override fun shutdown() = TODO("not implemented")
    override fun <T : Any?> submit(task: Callable<T>?): Future<T> = TODO("not implemented")
    override fun <T : Any?> submit(task: Runnable?, result: T): Future<T> = TODO("not implemented")
    override fun submit(task: Runnable?): Future<*> = TODO("not implemented")
    override fun shutdownNow(): MutableList<Runnable> = TODO("not implemented")
    override fun isShutdown(): Boolean = TODO("not implemented")
    override fun awaitTermination(timeout: Long, unit: TimeUnit?): Boolean = TODO("not implemented")
    override fun isTerminated(): Boolean = TODO("not implemented")
    override fun <T : Any?> invokeAny(tasks: MutableCollection<out Callable<T>>?): T = TODO(
            "not implemented")

    override fun <T : Any?> invokeAny(tasks: MutableCollection<out Callable<T>>?, timeout: Long,
                                      unit: TimeUnit?): T = TODO("not implemented")

    override fun <T : Any?> invokeAll(
            tasks: MutableCollection<out Callable<T>>?): MutableList<Future<T>> = TODO("not implemented")

    override fun <T : Any?> invokeAll(tasks: MutableCollection<out Callable<T>>?, timeout: Long,
                                      unit: TimeUnit?): MutableList<Future<T>> = TODO("not implemented")

    override fun execute(command: Runnable?) {
        command?.run()
    }
}