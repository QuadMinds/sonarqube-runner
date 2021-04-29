# Download and untar Android SDK tools
mkdir -p /app/android-sdk-linux \
    && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O tools.zip \
    && unzip tools.zip -o -d /app/android-sdk-linux \
    && rm tools.zip

# Set environment variable
export ANDROID_HOME=/app/android-sdk-linux
export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}

chmod 777 -R ${ANDROID_HOME}
chmod 777 -R /app

# Make license agreement
mkdir ${ANDROID_HOME}/licenses \
    && echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license \
    && echo d56f5187479451eabf01fb78af6dfcb131a6481e >> ${ANDROID_HOME}/licenses/android-sdk-license \
    && echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> ${ANDROID_HOME}/licenses/android-sdk-license \
    && echo 84831b9409646a918e30573bab4c9c91346d8abd > ${ANDROID_HOME}/licenses/android-sdk-preview-license

# Update and install using sdkmanager
${ANDROID_HOME}/tools/bin/sdkmanager "tools" "platform-tools" \
    && ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;29" \
    && ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-29" \
    && ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"

yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

./gradlew lintKotlin
./gradlew detekt
# ./gradlew app:testDebugUnitTest
# ./gradlew passengertransfer:testDebugUnitTest
# ./gradlew common:testDebugUnitTest
# ./gradlew core:testDebugUnitTest
# ./gradlew tracing:testDebugUnitTest

./gradlew cleanBuildCache
./gradlew app:assembleRelease -Penvironment='git'
