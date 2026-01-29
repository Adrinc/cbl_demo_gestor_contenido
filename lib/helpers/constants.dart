//////// DEV CBLUNA ////////
const String supabaseUrl = 'https://cbl-supabase.cbluna-dev.com';
const String anonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzE1MjM4MDAwLAogICJleHAiOiAxODczMDA0NDAwCn0.qKqYn2vjtHqKqyt1FAghuIjvNsyr9b1ElpVfvJg6zJ4';
const String storageBooksCover =
    'https://cbl-supabase.cbluna-dev.com/storage/v1/object/public/lectores_urb/books_cover/';
const String storageBooks = 'lectores_urb/books';

const redirectUrl = '$supabaseUrl/change-pass/change-password/token';

const String apiGatewayUrl = 'https://cbl.cbluna-dev.com/uapi/lu/api';
const String n8nUrl = 'https://u-n8n.cbluna-dev.com/webhook';
const bearerApiGateway = "Basic YWlyZmxvdzpjYiF1bmEyMDIz";

const int organizationId = 17;
const String lectoresUrl = 'https://lectoresurbanos.com/';

const themeId = String.fromEnvironment('themeId', defaultValue: '2');
const int mobileSize = 800;

//GoogleMaps
const apiKey = '-plDP_dR7XAGxBSiHgTFyxkxNdjFFHqjQK9ge8b92CE';

//Stripe
const stripeKey =
    'sk_test_51QB3lZRxye2e7dlWyeWcHWmgsJ9kEbIz4lrgJtUIKuC7WEB0HM0njk6Mcgq1q1H9GTs7fByRZdvxHaSAGhzcBqYF00fLxZU9E9';
const authorizationKey = 'Bearer $stripeKey';

const urlStripe = 'https://api.stripe.com';
const idPricePlanRentaQR = 'price_1QPaDnRxye2e7dlWORf4GoHS';
