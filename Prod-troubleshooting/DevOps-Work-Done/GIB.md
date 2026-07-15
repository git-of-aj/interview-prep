## GIB Base url 
> src/main/resources/application-local.properties
## mvn cmds
```java
mvn -v 
mvn clean package
java -jar gibservice-0.0.1-SNAPSHOT.jar
```
🌟 Why JAR Files are Portable
The reason for this platform independence lies in how Java executes code:

- Compilation to Bytecode: When you build your Java code on Windows, the Java compiler (javac) converts the source code (.java files) into platform-neutral bytecode (.class files). These bytecode files are packaged into the JAR file.

- Java Virtual Machine (JVM): When you run the JAR on Ubuntu, the JVM (Java Virtual Machine) on that machine takes the bytecode and translates it into the native machine code specific to the Ubuntu operating system and its hardware

| **Potential Pitfall**    | **Description**                                                                                                                                                                                                                   | **Resolution**                                                                                                    | **Impact**                                                                                   |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| Java Version Mismatch    | The most common issue. The JAR was compiled with a newer Java version (e.g., Java 17) but is run with an older JRE on Ubuntu (e.g., Java 11).                                                                                    | Ensure the JRE version on Ubuntu is the same or newer than the version used to compile the JAR.                  | Application fails to start with UnsupportedClassVersionError; deployment blocked.            |
| File Path Separators     | Windows uses backslash (\) as a path separator, while Linux/Ubuntu uses forward slash (/). If your code uses hardcoded Windows paths (e.g., C:\data\file.txt), it will fail on Ubuntu.                                            | Use java.io.File.separator or the Path API (java.nio.file) which resolves the correct separator at runtime.      | File not found errors; features relying on file I/O break; potential data read/write issues. |
| Case Sensitivity         | Windows file systems are usually case-insensitive, but Ubuntu/Linux file systems are case-sensitive. If your code references a resource file as config.yml but it's named Config.yml inside the JAR, it will fail on Ubuntu.      | Ensure all file and resource names in your code match their actual case exactly.                                  | Resource loading failures; configuration not applied; runtime errors or misbehavior.         |
| Native Libraries (JNI)   | If your application uses Java Native Interface (JNI) to call OS-specific code (e.g., using a Windows .dll), that library must be replaced with a Linux equivalent (.so) and packaged with the JAR.                                | Provide platform-specific builds or conditional loading of native libraries; include correct .so for Linux.       | UnsatisfiedLinkError; critical functionality disabled; application crash at runtime.         |
