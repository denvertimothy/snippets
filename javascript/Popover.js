/*\
|*| Popover.js
|*|
|*| Author: Ian Timothy, Thrive Data <ian@thrivedata.it>
|*| License: BSD
\*/


customElements.define('thrive-popover',
	class extends HTMLElement
	{
		constructor()
		{
			super();
			const shadowRoot = this.attachShadow({mode: 'open'});

			shadowRoot.innerHTML = `
				<style>
					:host {
						display: none;
						position: absolute;
						padding: 0.5rem;
						border: 1px solid #ccc;
						border-radius: 3px;
						background: white;
						box-shadow: 0px 5px 5px 2px rgba(0, 0, 0, 0.2);
						z-index: 1000;
						width: max-content;
						text-align: left;
						font-weight: normal;
					}
					:host([open]) {
						display: block;
					}
				</style>
				<slot></slot>
			`;

			this.handle = null;
		}

		openclose()
		{
			let h = this.toggleAttribute('open');
			this.position();
			this.dispatchEvent(new CustomEvent('openclose', {bubbles: true, detail: {'open': h}}));
		}

		open()
		{
			this.setAttribute('open', '');
			this.position();
			this.dispatchEvent(new CustomEvent('close', {bubbles: true}));
		}

		close()
		{
			this.removeAttribute('open');
			this.dispatchEvent(new CustomEvent('close', {bubbles: true}));
		}

		position()
		{
			/*
				window.inner{Width,Height}
					- includes scrollbars
				document.documentElement.client{Width,Height}
					- does not include scrollbars
				getBoundingClientRect
					- relative to the viewport
					- includes padding and border unless box-sizing:border-box is set
			*/

			let _h = this.handle.getBoundingClientRect();
			let _p = this.getBoundingClientRect();
			let _b = document.body.getBoundingClientRect();

			let _top = _h.bottom + window.scrollY + 3;
			let _left = _h.left + window.scrollX;
			let _width = '';

			if (_p.width > _b.width) {
				// popover is wider than body
				_width = _b.width - (document.documentElement.offsetWidth - _b.width);
				_left = _b.left;
			}
			else if (_h.left + _p.width > _b.right) {
				// popover is off screen
				_left = _b.right - _p.width;
			}

			this.style.top = `${_top}px`;
			this.style.left = `${_left}px`;
			this.style.width = `${_width}px`;
		}

		setupHandle()
		{
			let self = this;
			this.handle = document.getElementById(this.getAttribute('handle'));
			this.handle.style.cursor = 'pointer';
			this.handle.addEventListener('click', ev => {
				self.openclose();
			});
		}

		connectedCallback()
		{
			this.getRootNode().addEventListener('DOMContentLoaded', ev => {
				this.setupHandle();
			});

			// set focus when popover is shown
			this.addEventListener('openclose', ev => {
				if (ev.detail.open) {
					let f = this.querySelector('.focus');
					if (f) {
						f.focus();
					}
				}
			});

			// close when clicking outside popover and handle
			this.getRootNode().documentElement.addEventListener('click', ev => {
				if (!this.contains(ev.target) && !this.handle.contains(ev.target)) {
					this.close();
				}
			});

			// reposition popover if off screen
			window.addEventListener('resize', () => {
				let open = !(window.getComputedStyle(this).display == 'none');
				if (open) {
					this.position();
				}
			});
		}
	}
);
