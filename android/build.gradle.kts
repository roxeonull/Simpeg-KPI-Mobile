allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val proj = this
    fun applyCompileSdk() {
        val android = proj.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.compileSdkVersion(36)
    }

    if (proj.state.executed) {
        applyCompileSdk()
    } else {
        proj.afterEvaluate {
            applyCompileSdk()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
