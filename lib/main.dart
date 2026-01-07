/// Echo Memory - Main Entry Point (Staging)
/// Default entry point uses staging environment

import 'main_common.dart';
import 'core/network/environment_config.dart';

void main() {
  // Default to staging environment
  EnvironmentConfig.init(Environment.staging);
  mainCommon();
}
