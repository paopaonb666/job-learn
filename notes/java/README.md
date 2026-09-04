# Java

> 状态：过了一遍 | 自评：基础/集合能讲，并发/JVM 待补 | 最后更新：2026-09-04

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

## 五、第一轮补充：自己的话（2026-09-04）

> 对应推进路线 #1「Java 基础 / 集合」。第二轮继续往下补。

### 1. String / StringBuilder / StringBuffer 怎么选

String 每次"修改"都是 new 一个新对象，循环里拼字符串会炸出一堆垃圾。
单线程拼接用 StringBuilder， StringBuffer 加了 synchronized，**除非真的在多线程里共享同一个
buffer，否则别用**——大多数拼接发生在方法内部，变量根本没逃逸出去，那个锁纯属白给。
JDK 9 之后 `String` 的 `value` 从 `char[]` 换成 `byte[]` + 一个编码标记位，
纯拉丁字符每个字符只占 1 字节，堆占用直接砍一半。

### 2. String 不可变是三件事一起撑起来的

不是靠一个 `final` 就完事了，缺一个都会漏：

1. `value` 数组是 `private final`，外部拿不到引用
2. 类是 `final`，不能被继承后改写行为
3. 所有看着像"修改"的方法（`concat`、`substring`、`replace`）都是返回新对象

能换来什么：字符串常量池能复用（不用拷贝）、`hashCode` 可以缓存（所以 String 特别适合做 HashMap 的 key）、
天然线程安全。代价是频繁修改必须靠 StringBuilder。

### 3. 泛型擦除 —— 一个事实的三种表现

运行时只有裸类型 `List`，泛型只活在编译期，编译器负责插入 `checkcast`。这一个事实推出三个常考结论：

- `List<String>` 和 `List<Integer>` 的 `.getClass()` 是**同一个对象**
- `instanceof` 后面不能带泛型参数（`o instanceof List<String>` 编译不过）
- **反射可以往 `List<String>` 里塞 Integer**，而且塞进去之后读出来做 `get()` 才会炸（`checkcast` 在读取时才触发）

另外方法重载时 `void f(List<String>)` 和 `void f(List<Integer>)` 会报"名称冲突"，
因为擦除后签名一模一样。

### 4. finally 里不要 return

finally 里的 `return` 会把 try/catch 里已经算好的返回值**覆盖掉**，
更糟的是如果 try 里正抛着异常，异常会被直接吞掉，排查时看不到任何痕迹。
另一个坑：finally 里修改基本类型的返回值**无效**，因为返回值在 return 那一刻已经存到操作数栈了，
之后再改局部变量没用（改引用对象的属性是有效的）。

### 5. 反射慢在哪，怎么救

慢在三件事，正好对应三种优化：

| 慢的原因 | 怎么救 |
| --- | --- |
| 按字符串查找 Method/Field | 缓存 Method 对象，别每次 `getMethod` |
| JIT 没法内联，调用走的是动态派发 | 少用，或者用 MethodHandle / LambdaMetafactory |
| 每次都要做访问控制检查 | `setAccessible(true)` 关掉检查 |

所以 Spring 这类框架都是启动时扫一遍注解、把元数据缓存起来，运行期只查缓存不走反射。

### 6. ArrayList 扩容：为什么是 1.5 倍

`newCapacity = oldCapacity + (oldCapacity >> 1)`，用右移代替除法。

选 1.5 而不是 2 的考虑：扩容太激进（比如 2 倍）浪费内存，太保守（1.1 倍）又频繁拷贝。
1.5 倍下，前面几轮释放掉的旧数组加起来的容量，有机会容纳后面某次扩容的需求，
内存块可以复用——这是"扩容次数"和"内存浪费"之间的一个折中点。
另外 ArrayList 默认初始容量 10，如果一开始就知道要放几百个元素，
直接在构造里给容量，能省掉好几次 `Arrays.copyOf`。

### 7. HashMap：四个为什么

**为什么扰动高低 16 位**：下标是 `hash & (n-1)`，数组小的时候只有低几位参与运算，
高位信息全部丢失。`h ^ (h >>> 16)` 把高位混进低位，减少碰撞。

**为什么容量是 2 的幂**：只有 2 的幂时 `hash & (n-1)` 才等价于 `hash % n` 且更快。
附带好处：扩容时元素的新下标只可能是「原位」或「原位 + 旧容量」，
不用重新算 hash，JDK 8 就靠这个把每个桶拆成高低两条链表直接搬。

**为什么负载因子 0.75**：空间利用率和碰撞概率的折中。太低数组空着浪费，
太高链表变长查询退化成 O(n)。0.75 是实测和理论（泊松分布）都比较舒服的点。

**为什么树化阈值 8、退化阈值 6**：0.75 负载因子下，桶里元素个数服从泊松分布，
长度达到 8 的概率已经低到千万分之一量级——也就是说正常 hash 下根本不会树化，
真树化了说明 hash 函数有问题。退化阈值取 6 而不是 8，是为了留 2 的缓冲，
避免刚树化又退化、反复横跳。

**JDK 7 的头插死循环**：并发 resize 时头插法会把链表反转，
两个线程同时反转同一个链表可能形成环，之后 `get()` 就死循环。JDK 8 改成尾插 + 拆链表解决了这个，
但 HashMap 依然不是线程安全的，并发场景该用 ConcurrentHashMap。

### 8. ConcurrentHashMap：锁粒度越来越细

演进主线就是一句话——**把锁的范围不断缩小**。

- **JDK 7**：分段锁 `Segment`，每个 Segment 继承 ReentrantLock，管一段桶。
  并发度等于 Segment 数量（默认 16）。不同 Segment 之间能真正并发写，但同一个 Segment 还是要排队，
  粒度仍然偏粗。
- **JDK 8**：直接锁**数组的单个桶**（synchronized 锁桶的头结点）。桶是空的就用 CAS 插入，
  连锁都不加。粒度从"一段桶"降到"一个桶"，并发度随容量增长，理论上限就是数组长度。

为什么 JDK 8 敢用 synchronized 而不是继续用 ReentrantLock：
JDK 6 之后 synchronized 做了偏向锁、轻量级锁这些优化，在低竞争的桶级别场景下开销已经和
ReentrantLock 差不多，而且 synchronized 是 JVM 内置、占用空间更小、还能被 JIT 优化掉。
另外 `size()` 这类全局统计用 `CounterCell[]` 分段计数再求和（类似 LongAdder 的思路），
避免所有线程抢一个变量。

**注意**：ConcurrentHashMap 保证的是单个操作的线程安全，
`if (!map.containsKey(k)) map.put(k, v)` 这种复合操作仍然不是原子的，
要用 `putIfAbsent` / `computeIfAbsent`。
