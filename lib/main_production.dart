/// Echo Memory - Production Entry Point
/// Use this for production builds

import 'main_common.dart';
import 'core/network/environment_config.dart';

void main() {
  EnvironmentConfig.init(Environment.production);
  mainCommon();
}
