var className = {
    selected: 'is-selected',
    hidden: 'is-hidden',
    active: 'active',
    open: 'is-open',
    disabled: 'disabled',
    hover: 'is-hover'
};

$(document).ready(function() {

    $('.js-remaining-characters').on('keyup',  function() {
        var targetElement = $(this).data('target-element'),
            targetID = $(this).data('target-id'),
            target = $(document).find(targetElement+'[data-id='+targetID+']'),
            maxCharacterLength = $(this).data('max-length'),
            enteredCharacters = $(this).val().length;

            target.text(maxCharacterLength-enteredCharacters);

            if (enteredCharacters > maxCharacterLength) {
                target.parents('.input-remaining').addClass('error');
            } else {
                target.parents('.input-remaining').removeClass('error');
            }
    });

    $('.js-tabs').on('click', '.tabs a', function(event) {
        event.preventDefault();
        var self = $(this),
            parent = self.parents('.js-tabs'),
            targetPane = self.parent('li').data('target');
        self.parents('li').addClass(className.active).siblings().removeClass(className.active);
        parent.find(targetPane).addClass(className.open).siblings().removeClass(className.open);
    });

    $('#js-main-nav').on('click', function(event) {
        event.preventDefault();
        $(this).next('.sub-nav').toggleClass(className.open);
    });

    $('.js-datepicker').datepicker({
        dateFormat: 'MM dd yy'
    });

    $('.js-match-height .group-container').matchHeight();

    /* ----------------------------------------
        New Campaign
    ------------------------------------------- */
    $('.js-radio-list').on('click', '.user-input', function() {
        $(this).parents('li').addClass(className.selected).siblings().removeClass(className.selected);
    }).on('change', '.user-input:checked', function() {
        var value = $(this).val();
        if (value === 'audience-option-3') {
            $('.process-2-steps').removeClass(className.hidden);
            $('.process-4-steps').addClass(className.hidden);
        } else {
            $('.process-2-steps').addClass(className.hidden);
            $('.process-4-steps').removeClass(className.hidden);
        }
    });
    
    $('.js-template-list').on('click', '.user-input', function() {
        var self = $(this);
        self.parents('.list-item').toggleClass(className.selected).siblings().removeClass(className.selected).find('.user-input').prop('checked', false);
    });

    /* ----------------------------------------
        Sticky Footer
    ------------------------------------------- */
    var body = $('body'),
        pageFooter = $('.page-footer');

    var bodyHeight,
        footerHeight,
        appHeight;

    var stickyFooter = function() {
        bodyHeight = body.height();
        footerHeight = pageFooter.outerHeight();
        appHeight = $('.app-container').outerHeight();
        // if ((bodyHeight - footerHeight) > appHeight) {
        if (bodyHeight > appHeight) {
            pageFooter.attr('data-is-sticky', 'true');
        } else {
            pageFooter.attr('data-is-sticky', 'false');
        }
    };

    stickyFooter();

    /* ----------------------------------------
        Modal
    ------------------------------------------- */

    var closeModal = function() {
        $('#js-modal').addClass(className.hidden);
        body.attr('data-is-modal-open', 'false');
        $('.js-champaign-actions').val('default');
    };

    var openModal = function() {
        $('#js-modal').removeClass(className.hidden);
        body.attr('data-is-modal-open', 'true');


        // targetModal = $(this).data('target-modal');
        // test = $('#js-modal-rename-campaign').html();

        // console.log($(this));
        // alert(test);

        // $('#js-modal-dialog').html(targetModal);
    };
    
    // tmpl($('id-of-script-tag').html())(data);

    $('.js-open-modal').on('click', function(event) {
        if (!$(this).hasClass('select')) {
            event.preventDefault();

            if (!$(this).hasClass('disabled')) {
                var targetModal = $(this).data('target-modal');
                $('.modal-content').addClass(className.hidden);
                $(targetModal).removeClass(className.hidden);
                openModal();
            }
        }
    }).on('change', function(event) {
        var selected = $(this).find('option:selected'),
            targetModal = selected.data('target-modal'),
            selectedValue = selected.val();
        if (selectedValue !== 'default') {
            $('.modal-content').addClass(className.hidden);
            $(targetModal).removeClass(className.hidden);
            openModal();
        }
    });

    $('#js-modal').on('click', '.js-close-modal', function(event) {
        event.preventDefault();
        closeModal();
    });

    $('.js-form-continue-validation').on('click', function() {
        var target = $(this).data('target-button');
        if ($(this).find('.user-input:checked').length) {
            $(target).removeClass(className.disabled);
        }
    });
    

    $('.js-clear-form').on('click', function() {

        $('.user-input.radio').prop('checked', false);
        $('.js-radio-list li').removeClass(className.selected);
        $('.button[data-default-state="disabled"]').addClass(className.disabled);
        $('.process-2-steps').addClass(className.hidden);
        $('.process-4-steps').removeClass(className.hidden);
    });

    $('#js-radio-list-audience').on('change', '.user-input:checked', function() {
        $('#js-radio-list-geo-selection .user-input.radio').prop('checked', false);
        $('#js-radio-list-geo-selection li').removeClass(className.selected);
    });

    $(document).on('click', '.js-remove-field', function() {
        $(this).parents('.js-target-field').remove();
    });

    $('.js-add-field').on('click', function(event) {
        event.preventDefault();
        var target = $(this).data('target-field'),
            html = $(target).html();
        $(this).parents('.add-field').before(html);
        console.log(html);
    });

    /* ----------------------------------------
        Load
    ------------------------------------------- */
    $(window).load(function() {
    });

    /* ----------------------------------------
        Resize
    ------------------------------------------- */
    $(window).resize(function() {
        stickyFooter();
    });
    
});

