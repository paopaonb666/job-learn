# Java

> 状态：未开始 | 自评：- | 最后更新：2026-09-03

## 一、Java 基础

- 面向对象三大特性；重载与重写的区别
- 接口与抽象类的区别；JDK 8 后接口的 default / static 方法
- String、StringBuilder、StringBuffer 的区别与使用场景
- String 为什么不可变；字符串常量池位置变化（JDK 7 从方法区移到堆）
- `==` 与 `equals()`；为什么重写 equals 必须重写 hashCode
- 自动装箱拆箱；Integer 缓存池（-128 ~ 127）
- 反射原理与性能开销；反射为什么慢
- 泛型与类型擦除；`List<String>` 和 `List<Integer>` 运行时是否同一类型
- 异常体系：checked / unchecked；finally 中不 return 的原因
- 注解原理；元注解 @Target @Retention
- 深拷贝与浅拷贝

## 二、集合

- ArrayList 扩容机制（1.5 倍）、与 LinkedList 的取舍
- **HashMap 源码**：hash 扰动、数组 + 链表 + 红黑树、扩容 resize、树化阈值（8）与退化阈值（6）
- HashMap 为什么容量是 2 的幂；为什么是 0.75 负载因子
- HashMap 在 JDK 7 的头插法死循环问题
- ConcurrentHashMap：JDK 7 分段锁 vs JDK 8 CAS + synchronized
- HashSet 如何实现去重；LinkedHashMap 的 LRU 实现
- PriorityQueue 堆实现；TreeMap 红黑树
- fail-fast 与 fail-safe

## 三、并发（面试重中之重）

- 进程与线程、协程的区别
- 线程的生命周期与状态流转；start() 与 run() 的区别
- 实现线程的几种方式；为什么推荐线程池而不是 new Thread
- **JMM 与 happens-before 规则**
- volatile：可见性、禁止指令重排、不保证原子性；DCL 单例为什么要 volatile
- synchronized：三种用法、对象头 Mark Word、锁升级（无锁→偏向→轻量→重量）
- synchronized 与 ReentrantLock 的区别；AQS 原理
- CAS 与 ABA 问题；AtomicStampedReference
- 线程池：7 个参数、工作流程、拒绝策略；为什么不推荐 Executors 创建
- ThreadLocal 原理与**内存泄漏**问题
- CountDownLatch / CyclicBarrier / Semaphore 的区别
- 死锁四个必要条件与排查手段（jstack）
- 虚假唤醒；为什么 wait() 要放在 while 循环里

## 四、JVM

- 运行时数据区：堆、方法区/元空间、虚拟机栈、本地方法栈、程序计数器
- 对象创建过程；对象内存布局；对象头有什么
- 判断对象可回收：引用计数 vs 可达性分析；GC Roots 有哪些
- 四种引用：强、软、弱、虚；ThreadLocal 里的弱引用
- 垃圾回收算法：标记-清除、标记-复制、标记-整理
- 分代收集；Minor GC / Major GC / Full GC 触发条件
- 常见收集器：Serial、Parallel、CMS、G1、ZGC 的特点与取舍
- 类加载过程：加载、验证、准备、解析、初始化
- 双亲委派模型；如何打破（Tomcat、JDBC、OSGi）
- OOM 类型与排查：jps / jstat / jmap / jstack / MAT
- JVM 调优参数：-Xms -Xmx -Xss -XX:NewRatio -XX:SurvivorRatio

## 高频追问

- new 一个对象的过程？
- synchronized 锁升级能不能降级？
- 线程池参数怎么设？CPU 密集和 IO 密集分别怎么配？
- G1 为什么能低延迟？Remembered Set 是干嘛的？
