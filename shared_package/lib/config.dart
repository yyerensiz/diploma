//shared_package\lib\config.dart
library carenest_config;

const String API_BASE = 'http://192.168.0.230:5000';
const String URL_AUTH_ME = '$API_BASE/api/auth/me';
const String URL_REGISTER = '$API_BASE/api/auth/register';

const String URL_SPECIALISTS  = '$API_BASE/api/specialists';

const String URL_REVIEWS = '$API_BASE/api/reviews';

const String URL_MONEY_BASE = '$API_BASE/api/money';
const String URL_WALLET = '$URL_MONEY_BASE/wallet';
const String URL_SUBSIDIES = '$URL_MONEY_BASE/subsidies';
const String URL_APPLY_SUBSIDY = '$URL_SUBSIDIES/apply';
const String URL_REPLENISH = '$API_BASE/api/money/replenish';


const String URL_ORDERS_BASE    = '$API_BASE/api/orders';
const String URL_CREATE_ORDER   = URL_ORDERS_BASE;
const String URL_CLIENT_ORDERS  = '$URL_ORDERS_BASE/client';
const String URL_UPDATE_ORDER   = URL_ORDERS_BASE;

const String URL_INFO_PANELS = '$API_BASE/api/info-panels';

const String URL_CHILDREN_BASE = '$API_BASE/api/children';
const String URL_CHILDREN      = URL_CHILDREN_BASE;
const String URL_CHILDREN_MY   = '$URL_CHILDREN_BASE/my';

const String URL_UPDATE_USER = '$API_BASE/api/users/:id';
const String URL_CREATE_CHILD  = '$API_BASE/api/children';

const String URL_SPECIALIST_PROFILE = '$API_BASE/api/specialists/profile';