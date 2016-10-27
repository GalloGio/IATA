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

    var body = $('body');

    body.on('click', function() {
        closeModal();
        $('.tooltip-container').removeClass(className.open);
    });

    $('.modal-header, .modal-body, .modal-footer, .tooltip-container').on('click', function(event) {
        var target = event.target;
        if (!$(target).hasClass('fa-times') || !$(target).hasClass('fa-exclamation-triangle')) {
            event.stopPropagation();
            console.log(target);
        }
    });



    $(document).on('keyup', '.js-remaining-characters', function() {
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

    $(document).on('click', '.js-enable-accordion', function() {
        var self = $(this),
            parent = self.parents('.js-accordion'),
            target = self.data('target');
        
        if ($(this).is(':checked')) {
            $(target).removeClass('is-disabled');
            parent.find('.accordion-panel[data-index="1"], .accordion-title[data-index="1"]').removeClass('is-open');
            parent.find('.accordion-panel[data-index="3"], .accordion-title[data-index="3"]').addClass('is-open');
        } else {
            $(target).addClass('is-disabled');
            // parent.find('.accordion-panel, .accordion-title').addClass('is-open');
            parent.find('.accordion-panel[data-index="1"], .accordion-title[data-index="1"]').addClass('is-open');
            parent.find('.accordion-panel[data-index="3"], .accordion-title[data-index="3"]').removeClass('is-open');
        }

    });


    var element = $('.is-sticky-container');
    var elementTop = $('.main-content > .inner-wrapper').offset().top;
    var elementWidth = element.width();
    var elementHeight = element.outerHeight(true) ;

    var stickyContainer = function() {
        if ($('#js-page-top').length) {
            var doc = document.documentElement,
                top = (window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);
            
            if (top > 50) {
                $('#js-page-top').removeClass(className.hidden);
            } else {
                $('#js-page-top').addClass(className.hidden);
            }   

            console.log(elementTop);
            if (elementTop < top) {
                element.addClass('fixed');
                $('.stikcy-adjuster').removeClass(className.hidden);
                element.css('width', elementWidth);
            } else {
                element.removeClass('fixed');
                $('.stikcy-adjuster').addClass(className.hidden);
                element.removeAttr('style');
            }
            

            $('.stikcy-adjuster').css({
                'height': elementHeight,
                'width': elementWidth
            });
        }
    };

    stickyContainer();


    $(document).on('click', '.js-selectable-row .user-input', function() {
        if ($(this).is(':checked')) {
            $(this).parents('tr').addClass(className.selected).siblings().removeClass(className.selected);
        } else {
            $(this).parents('tr').removeClass(className.selected);
        }
    });

    var stickyElementContainerWidth,
        stickyElementPositionTop;
    $(document).on('click', '.js-tabs .tabs a', function(event) {
        event.preventDefault();
        var self = $(this),
        parent = self.parents('.js-tabs'),
        targetPane = self.parent('li').data('target');
        self.parents('li').addClass(className.active).siblings().removeClass(className.active);
        parent.find(targetPane).addClass(className.open).siblings().removeClass(className.open);
        activateEllipsisTooltip();
        stickyFooter();
        if ($('.sub-container.payment-confirmation').length) {
            var targetStickyElement = parent.find(targetPane + ' .sub-container.payment-confirmation');
            stickyElementContainerWidth = targetStickyElement.width();
            stickyElementPositionTop = targetStickyElement.offset().top;

        }

    });

    var isClicked = false;
    $('.js-page-anchors').on('click', 'li',  function(event) {
        $(this).addClass(className.active).siblings().removeClass(className.active);
        var target = $(this).find('a').attr('href');
        // $(target).css({
        //     'padding-top': elementHeight
        // });
        // $(target).siblings('.group-container').removeAttr('style');
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

    $(document).on('vclick click', '.js-tooltip', function(event) {
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
    $('.list.addon-list .list-item').matchHeight();
    
    /* ---------------------------------------- */
    /*  Payment Method                            */
    /* ---------------------------------------- */
    $(document).on('change', '.js-payment-method .user-input:checked', function() {
        var value = $(this).val();
        var parents = $(this).parents('.group-container.payment-info');
        if (value === 'ich') {
            parents.find('.payment-method-container').addClass(className.hidden);
            parents.find('.payment-method-container.bank').addClass(className.hidden);
            $('#js-method-bank-transfer').removeClass(className.hidden);
        }
        if (value === 'creditCard') {
            parents.find('.payment-method-container').removeClass(className.hidden);
            parents.find('.payment-method-container.bank').addClass(className.hidden);
            $('#js-method-bank-transfer').removeClass(className.hidden);
        }
        if (value === 'bank') {
            parents.find('.payment-method-container').addClass(className.hidden);
            parents.find('.payment-method-container.bank').removeClass(className.hidden);
            $('#js-method-bank-transfer').addClass(className.hidden);
        }
    });

    $(document).on('change', '.js-card-data-table .user-input', function() {
        $(this).parents('tr').addClass(className.selected).siblings().removeClass(className.selected);
    });
    
    /* ---------------------------------------- */
    /*  Radio Checkbox List                     */
    /* ---------------------------------------- */
    $(document).on('click', '.js-radio-list .user-input.radio', function() {
        $(this).parents('li').addClass(className.selected).siblings().removeClass(className.selected);
        stickyFooter();
    }).on('change', '.js-radio-list .user-input:checked', function() {
        var value = $(this).val();
        if (value === 'audience-option-3') {
            $('.process-2-steps').removeClass(className.hidden);
            $('.process-4-steps').addClass(className.hidden);
        } else {
            $('.process-2-steps').addClass(className.hidden);
            $('.process-4-steps').removeClass(className.hidden);
        }
    });
    
    $(document).on('click', '.js-template-list .user-input', function() {
        var self = $(this);
        self.parents('.list-item').toggleClass(className.selected).siblings().removeClass(className.selected).find('.user-input').prop('checked', false);
    });
    $(document).on('click', '.js-checkbox-list .user-input', function() {
        var self = $(this);
        self.parents('.list-item').toggleClass(className.selected).siblings().removeClass(className.selected).find('.user-input').prop('checked', false);
    });

    
    $(document).on('click', '.button', function(event) {
        if ($(this).is('.disabled')) {
            event.preventDefault();
        }
    });

    /* ---------------------------------------- */
    /*  From Validation                         */
    /* ---------------------------------------- */
    $(document).on('focus', '.user-input', function() {
        $(this).parents('.field-group').addClass('is-focus');
    }).on('blur', '.user-input', function() {
        $(this).parents('.field-group').removeClass('is-focus');
    }).on('keyup', '.user-input', function() {
        if ($(this).val().length) {
            $(this).parents('.field-group').removeClass('is-focus').removeClass('error');
        }
    }).on('change', '.user-input', function() {
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
        pageFooter.attr('data-is-sticky', 'false');
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

    $(document).on('click', '.js-accordion .accordion-title', function() {
        
        if ($(this).is('.is-disabled')) {
        } else {
            $(this).toggleClass(className.open).next().toggleClass(className.open);
        }

        stickyFooter();
    });
    
    $(document).on('click', '.js-toggle-type-sort', function(event) {
        event.preventDefault();
        event.stopPropagation();
        $(this).toggleClass(className.open).next().toggleClass(className.open);
    });

    $(document).on('click', '.type-sort', function(event) {
        event.stopPropagation();
    });

    body.on('click',  function() {
        $('.js-toggle-type-sort').removeClass(className.open).next().removeClass(className.open);
    });

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
    $(document).on('click', '.js-open-modal', function(event) {
        if (!$(this).hasClass('select')) {
            event.preventDefault();

            if (!$(this).hasClass('disabled')) {
                var targetModal = $(this).data('target-modal');
                $('.modal-content').addClass(className.hidden);
                $(targetModal).removeClass(className.hidden);
                openModal();
            }
        }
    }).on('change', '.js-open-modal', function(event) {
        var selected = $(this).find('option:selected');
        
        selectedCampainID = this.getAttribute('data-target-campaign-id');
        
        var targetCampaignName = $('#' + selectedCampainID).find('.js-campaign-name').html(),
            targetModal = selected.data('target-modal'),
            selectedValue = selected.val();

        if (selectedValue !== 'default') {
            $(targetModal).find('.js-get-campaign-name').html(targetCampaignName);
            $(targetModal).find('.user-input.js-get-campaign-name').val(targetCampaignName);
            $('.modal-content').addClass(className.hidden);
            $(targetModal).removeClass(className.hidden);
            openModal();
        }
    });

    $(document).on('click', '.js-delete-campaign', function(event) {
        event.preventDefault();
        $('#' + selectedCampainID).remove();
        closeModal();
    });

    $(document).on('click', '.js-rename-campaign', function(event) {
        event.preventDefault();
        var newCampaignName = $('.user-input.js-get-campaign-name').val();
        $('#' + selectedCampainID).find('.js-campaign-name').html(newCampaignName);
        closeModal();
    });

    $(document).on('click', '.js-pause-campaign', function(event) {
        event.preventDefault();
        $('#' + selectedCampainID).find('.js-icon-status').attr('data-icon-type', 'pending');
        $('#' + selectedCampainID).find('.js-campaign-status').text('Pending');
        closeModal();
    });

    $(document).on('click', '#js-modal .js-close-modal', function(event) {
        event.preventDefault();
        closeModal();
    });

    $(document).on('click', '.js-form-continue-validation', function() {
        var target = $(this).data('target-button');
        if ($(this).find('.user-input:checked').length) {
            $(target).removeClass(className.disabled);
        }
    });

    $(document).on('click', '.js-clear-form', function() {
        $('.user-input.radio').prop('checked', false);
        $('.js-radio-list li').removeClass(className.selected);
        $('.button[data-default-state="disabled"]').addClass(className.disabled);
        $('.process-2-steps').addClass(className.hidden);
        $('.process-4-steps').removeClass(className.hidden);
    });

    $(document).on('change', '#js-radio-list-audience.user-input:checked', function() {
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
    }

    var countRemovableField = function() {
        if (fieldCounter) {

        }
    };

    $(document).on('click', '.js-multi-select li', function() {
        $(this).addClass(className.selected).siblings().removeClass(className.selected);
    });

    $(document).on('click', '.js-add-field', function(event) {
        event.preventDefault();
        var target = $(this).data('target-field'),
            html = $(target).html();
        $(this).parents('.add-field').before(html);
        $('.js-remove-field').removeClass(className.hidden);
        numberOfFields++;
    });

    $(document).on('change', '.js-input-file', function() {
        var value = $(this).val();
        $(this).next('.user-input').val(value);
    });

    var stickyConfirmation = $('.is-sticky-confirmation'),
        stickyConfirmationPositionTop = (stickyConfirmation.length) ? $(stickyConfirmation[0]).offset().top : '';

    var stickyElement = function() {
        var scrollTop = $(window).scrollTop();
        var containerWidth = $(stickyConfirmation[0]).width();
        if (scrollTop > stickyConfirmationPositionTop) {
            stickyConfirmation.addClass('fixed');
            stickyConfirmation.css('width', containerWidth);
        } else {
            stickyConfirmation.removeClass('fixed');
            stickyConfirmation.removeAttr('style');
        }
    };

    var stickyElementWithTabs = function() {
        var scrollTop = $(window).scrollTop();

        if (scrollTop > stickyElementPositionTop) {
            $('.is-sticky-confirmation').addClass('fixed');
            $('.is-sticky-confirmation').css('width', stickyElementContainerWidth);
        } else {
            $('.is-sticky-confirmation').removeClass('fixed');
            $('.is-sticky-confirmation').removeAttr('style');
        }
    };

    $(window).scroll(function() {
        if ($('.main-content.manage-account').length) {
            stickyElementWithTabs();
        } else {
            stickyElement();
        }


        stickyContainer();
    });

    /* ---------------------------------------- */
    /*  Resize                                  */
    /* ---------------------------------------- */
    $(window).resize(function() {
        stickyFooter();
    });
    
});


