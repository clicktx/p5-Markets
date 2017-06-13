(
    # Preferences test
    # preferences
    'Preference' => [
        [ 'name', 'value', 'default_value', 'title', 'summary', 'position', 'group_id' ],
        [ 'pref_test1', undef, 'test1', '', '', 100, 1 ],
        [ 'pref_test2', undef, 'test2', '', '', 200, 1 ],
        [ 'pref_test3', undef, 'test3', '', '', 300, 1 ],
        [ 'pref_test4', undef, 'test4', '', '', 400, 1 ],
    ],

    # Addons
    'Addon' => [
        [qw/id name is_enabled/],
        [qw/1 test_addon 1/],
        [qw/2 disable_addon 0/],
    ],
    'Customer' => {
        id => 3,
        emails => [ { email => { address => 'c@x.org' } } ],
        password => { hash => 'SCRYPT:16384:8:1:lDuUwcU0iGJJt42hmZw/QSF1Zjuoucot8KL/YGyZCmY=:9gLPkZQbRqeFIJxmccG8m9AT/v/6ro0hRYlFLt0Td0M=' },
    },
)

# INSERT  INTO `markets`.`addons` (`id`, `name`, `is_enabled`)
# VALUES  (1, 'test_addon','1'),
#         (2, 'disable_addon', '0');

# -- Addon triggers
# -- -----------------------------------------------------
# 
# -- INSERT  INTO `markets`.`addon_triggers` (`id`, `addon_id`, `trigger_name`, `priority`)
# -- VALUES  (NULL, '1', 'before_compile_template', '300'),
# --         (NULL, '1', 'before_xxx_action', '500');
