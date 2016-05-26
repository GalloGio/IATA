var className = {
    selected: 'is-selected',
    hidden: 'is-hidden',
    active: 'active',
    open: 'is-open',
    disabled: 'disabled',
    hover: 'is-hover'
};

jQuery.noConflict();

jQuery(document).ready(function($) {

    var userInputs = $('.js-remaining-characters');

    for (var i = 0; i < userInputs.length; i++) {
        if ($(userInputs[i]).val().length) {
            var maxCharacterLength = $(userInputs[i]).data('max-length'),
                defaultCharacters = $(userInputs[i]).val().length;
            $(userInputs[i]).parents('.field-group').find('.js-remaining-count').text(maxCharacterLength-defaultCharacters);
        }
    }

    $('.js-remaining-characters').parents('.field-group text');

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
        activateEllipsisTooltip();
    });

    $('#js-main-nav').on('click', function(event) {
        event.preventDefault();
        $(this).next('.sub-nav').toggleClass(className.open);
    });

    $('.js-multi-select').on('click', function() {
        $(this).toggleClass(className.open).next().toggleClass(className.open);
    });

    var ellipsisWidth = 199;
    var ellipsisElements = $('.ellipsis');
    var activateEllipsisTooltip = function() {
        for (var i = 0; i < ellipsisElements.length; i++) {
            if ($(ellipsisElements[i]).width() > ellipsisWidth) {
                $(ellipsisElements[i]).addClass('is-ellipsis');
            }
        }
    };

    activateEllipsisTooltip();

    $(document).on('mouseenter', '.is-ellipsis',function() {
        $(this).next('.js-ellipsis-details').addClass(className.open);
    }).on('mouseout', '.is-ellipsis',function() {
        $(this).next('.js-ellipsis-details').removeClass(className.open);
    });

    /* ---------------------------------------- */
    /*  Tooltip                                 */
    /* ---------------------------------------- */

    $('.js-tooltip').on('vclick click', function(event) {
        event.preventDefault();
        $(this).next().toggleClass(className.open);
    });

    /* ---------------------------------------- */
    /*  Datepicker                              */
    /* ---------------------------------------- */
    $('.js-datepicker').datepicker({ 
        dateFormat: 'MM dd yy'
    });

    /* ---------------------------------------- */
    /*  Match Height                            */
    /* ---------------------------------------- */
    $('.js-match-height .group-container').matchHeight();

    /* ---------------------------------------- */
    /*  Payment Method                            */
    /* ---------------------------------------- */
    $('.js-payment-method').on('change', '.user-input:checked', function() {
        var value = $(this).val();
        console.log(0);
        if (value === 'ich') {
            $('.payment-method-container').addClass(className.hidden);
        }
        if (value === 'creditCard') {
            $('.payment-method-container').removeClass(className.hidden);
        }
    });

    $('.js-card-data-table .user-input').on('change', function() {
        $(this).parents('tr').addClass(className.selected).siblings().removeClass(className.selected);
    });
    
    /* ---------------------------------------- */
    /*  Radio Checkbox List                     */
    /* ---------------------------------------- */
    $('.js-radio-list').on('click', '.user-input.radio', function() {
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
    $('.js-checkbox-list').on('click', '.user-input', function() {
        var self = $(this);
        self.parents('.list-item').toggleClass(className.selected).siblings().removeClass(className.selected).find('.user-input').prop('checked', false);
    });

    
    $('.button').on('click', function(event) {
        if ($(this).is('.disabled')) {
            event.preventDefault();
        }
    });

    /* ----------------------------------------
        From Validation
    ------------------------------------------- */

    $('.user-input').on('focus', function() {
        $(this).parents('.field-group').addClass('is-focus');
    }).on('blur', function() {
        $(this).parents('.field-group').removeClass('is-focus');
    }).on('keyup', function() {
        if ($(this).val().length) {
            $(this).parents('.field-group').removeClass('is-focus').removeClass('error');
        }
    }).on('change', function() {
        if ($(this).val() !== 'select') {
            $(this).parents('.field-group').removeClass('is-focus').removeClass('error');
        }
    });
    
    /* ---------------------------------------- */
    /*  Sticky Footer                           */
    /* ---------------------------------------- */
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

    /* ---------------------------------------- */
    /*  Modal                                   */
    /* ---------------------------------------- */
    var closeModal = function() {
        $('#js-modal').addClass(className.hidden);
        body.attr('data-is-modal-open', 'false');
        $('.js-champaign-actions').val('default');
    };

    var openModal = function() {
        $('#js-modal').removeClass(className.hidden);
        body.attr('data-is-modal-open', 'true');
    };
    
    var selectedCampainID;
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
        var selected = $(this).find('option:selected');
        
        selectedCampainID = this.getAttribute('data-target-campaign-id');
        
        var targetCampaignName = $('#' + selectedCampainID).find('.js-campaign-name').html(),
            targetModal = selected.data('target-modal'),
            selectedValue = selected.val();

        if (selectedValue !== 'default') {
            console.log(targetCampaignName); 
            $(targetModal).find('.js-get-campaign-name').html(targetCampaignName);
            $(targetModal).find('.user-input.js-get-campaign-name').val(targetCampaignName);
            $('.modal-content').addClass(className.hidden);
            $(targetModal).removeClass(className.hidden);
            openModal();
        }
    });

    $('.js-delete-campaign').on('click', function(event) {
        event.preventDefault();
        $('#' + selectedCampainID).remove();
        closeModal();
    });

    $('.js-rename-campaign').on('click', function(event) {
        event.preventDefault();
        var newCampaignName = $('.user-input.js-get-campaign-name').val();
        $('#' + selectedCampainID).find('.js-campaign-name').html(newCampaignName);
        closeModal();
    });

    $('.js-pause-campaign').on('click', function(event) {
        event.preventDefault();
        $('#' + selectedCampainID).find('.js-icon-status').attr('data-icon-type', 'pending');
        $('#' + selectedCampainID).find('.js-campaign-status').text('Pending');
        closeModal();
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

    var removableFields,
        numberOfFields,
        fieldCounter;

    $(document).on('click', '.js-remove-field', function() {
        $(this).parents('.js-target-field').remove();
        numberOfFields--;
        if (numberOfFields < 2) {
            $('.js-remove-field').addClass(className.hidden);
        }
    });

    
    if ($('.js-count-removable-field').length) {
        removableFields= $('.js-target-field');
        numberOfFields = removableFields.length;
        console.log(numberOfFields);
    }

    var countRemovableField = function() {
        if (fieldCounter) {

        }
    };

    $('.js-multi-select').on('click', 'li', function() {
        $(this).addClass(className.selected).siblings().removeClass(className.selected);
    });

    $('.js-add-field').on('click', function(event) {
        event.preventDefault();
        var target = $(this).data('target-field'),
            html = $(target).html();
        $(this).parents('.add-field').before(html);
        $('.js-remove-field').removeClass(className.hidden);
        numberOfFields++;
    });

    $('.js-input-file').on('change', function() {
        var value = $(this).val();
        $(this).next('.user-input').val(value);
    });

    var stickyConfirmation = $('.is-sticky-confirmation'),
        stickyConfirmationPositionTop = (stickyConfirmation.length) ? stickyConfirmation.offset().top : '';

    var stickyElement = function() {
        var scrollTop = $(window).scrollTop();
        var containerWidth = $('.is-sticky-confirmation').width();
        if (scrollTop > stickyConfirmationPositionTop) {
            stickyConfirmation.addClass('fixed');
            stickyConfirmation.css('width', containerWidth);
        } else {
            stickyConfirmation.removeClass('fixed');
            stickyConfirmation.removeAttr('style');
        }
    };


    $(window).scroll(function() {
        stickyElement();
    });

    /* ---------------------------------------- */
    /*  Resize                                  */
    /* ---------------------------------------- */
    $(window).resize(function() {
        stickyFooter();
    });
    
});


