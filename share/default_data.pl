(
    # preferences
    'Preference' => [
        [ 'name', 'default_value', 'title', 'summary', 'position', 'group_id' ],

        # location
        [ 'locale_language_code', 'en', 'pref.title.locale_language_code', 'pref.summary.locale_language_code', 100, 1 ],
        [ 'locale_country_code', 'US', 'pref.title.locale_country_code', 'pref.summary.locale_country_code', 200, 1 ],
        [ 'locale_currency_code', 'USD', 'pref.title.locale_currency_code', 'pref.summary.locale_currency_code', 300, 1 ],

        # Decimal rounding mode 'even' or 'trunc'
        [ 'decimal_rounding_mode', 'even', 'pref.title.decimal_rounding_mode', 'pref.summary.decimal_rounding_mode', 400, 1 ],

        # shop master
        [ 'shop_name', 'Yetie Shop', 'pref.title.shop_name', 'pref.summary.shop_name', 100, 2 ],

        # staff
        [ 'staff_password_min', '4', 'pref.title.staff_password_min', 'pref.summary.staff_password_min', 100, 2 ],
        [ 'staff_password_max', '8', 'pref.title.staff_password_max', 'pref.summary.staff_password_max', 101, 2 ],

        # customer
        [ 'customer_password_min', '4', 'pref.title.customer_password_min', 'pref.summary.customer_password_min', 100, 2 ],
        [ 'customer_password_max', '8', 'pref.title.customer_password_max', 'pref.summary.customer_password_max', 101, 2 ],

        # application
        [ 'admin_uri_prefix', '/admin', 'pref.title.admin_uri_prefix', 'pref.summary.admin_uri_prefix', 100, 9 ],
        [ 'addons_dir', 'addons', 'pref.title.addons_dir', 'pref.summary.addons_dir', 200, 9 ],
        [ 'can_multiple_shipments', 0, 'pref.title.can_multiple_shipments', 'pref.summary.can_multiple_shipments', 300, 9 ],
        [ 'server_session_expires_delta', 3600, 'pref.title.server_session_expires_delta', 'pref.summary.server_session_expires_delta', 400, 9 ],
        [ 'server_session_cookie_expires_delta', 3600 * 24 * 365, 'pref.title.server_session_cookie_expires_delta', 'pref.summary.server_session_cookie_expires_delta', 500, 9 ],
        [ 'cookie_expires_long', 3600 * 24 * 365, 'pref.title.cookie_expires_long', 'pref.summary.cookie_expires_long', 600, 9 ],
    ],

    # tax rules
    'TaxRule' => [
        [ qw/id title tax_rate/],
        [ 1, 'Tax Exemption', 0 ],
    ],
)
