  Trix.config.blockAttributes['code'] = {
    tagName: 'cb',
    terminal: 'true',
    text: {
      plaintext: true
    }
  };  
  
  Trix.config.textAttributes['code2'] = {
    tagName: 'code',
    terminal: 'true',
    text: {
      plaintext: true
    }
  };    
  

  
  Trix.config.blockAttributes['pre'] = {
    tagName: 'pre',
    terminal: 'true',
    text: {
      plaintext: true
    }
  };
    
  document.addEventListener("trix-attachment-add", function(event) {
    var attachment;
    attachment = event.attachment;
    if (attachment.file) {
	  console.log(attachment.file);
	  attachment.setUploadProgress(100);
      attachment.setAttributes({
          url: 'https://manage.siteleaf.com/images/siteleaf-logo.svg'
      });
    }
  });    
    
  buttonHTML = '<button type="button" class="heading" data-trix-attribute="pre" title="Pre">Pre</button>';
  groupElement = Trix.config.toolbar.content.querySelector('.block_tools');
  groupElement.insertAdjacentHTML('beforeend', buttonHTML);

  buttonHTML = '<button type="button" class="heading" data-trix-attribute="code2" title="CodeInline">``</button>';
  groupElement = Trix.config.toolbar.content.querySelector('.text_tools');
  groupElement.insertAdjacentHTML('beforeend', buttonHTML);
  
  Trix.config.textAttributes.underline = {
    style: { 'textDecoration': 'underline' },
    inheritable: true
  }

  buttonHTML = '<button type="button" class="underline" data-trix-attribute="underline" title="underline">Underline</button>'
  groupElement = Trix.config.toolbar.content.querySelector('.text_tools')
  groupElement.insertAdjacentHTML('beforeend', buttonHTML)
