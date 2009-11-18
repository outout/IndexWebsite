package com.controls
{
	/* LoadingImage.as
	 * Created by Tony Fendall 19/05/08
	 *
	 * The LoadingImage component adds a mx.controls.ProgressBar 
	 * to the mx.controls.Image component which shows its own loading progress.
	 */
	 
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	import mx.controls.Image;
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarMode;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	public class LoadingImage extends Image
	{
		
//---------------------------------------------------------------------
// Private properties
//---------------------------------------------------------------------
		private var _progressBar:ProgressBar;		
		
		private var _progressPercentWidth:Number = 80;
		private var _progressHeight:Number = 20;
		
		
//---------------------------------------------------------------------
// Public properties
//---------------------------------------------------------------------
		
		/**
		 * The relative width of the progress bar
		 */
		public function set progressPercentWidth( value:Number ):void
		{
			_progressPercentWidth = value;
			evaluateProgressSize();
		}
		public function get progressPercentWidth():Number
		{
			return _progressPercentWidth;	
		}
		
		/**
		 * The height of the progress bar
		 */
		public function set progressHeight( value:Number ):void
		{
			_progressHeight = value;
			evaluateProgressSize();
			
		}
		public function get progressHeight():Number
		{
			return _progressHeight;
		}
		
		/**
		 * The progress bar label
		 */
		public function set progressLabel( value:String ):void
		{
			_progressBar.label = value;
		}
		public function get progressLabel():String
		{
			return _progressBar.label;
		}
		
		
//---------------------------------------------------------------------
// Constructior
//---------------------------------------------------------------------
		public function LoadingImage()
		{
			this.addEventListener( ResizeEvent.RESIZE, resizeHandler );
			this.addEventListener( Event.OPEN, openHandler );
			this.addEventListener( Event.COMPLETE, completeHandler );
			this.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			this.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		}
		
		
//---------------------------------------------------------------------
// Protected functions
//---------------------------------------------------------------------
		
		/**
		 * Create children override
		 * This is where the progress bar is created
		 */
		override protected function createChildren():void
		{
			_progressBar = new ProgressBar();
			_progressBar.addEventListener( FlexEvent.CREATION_COMPLETE, progressCreated );
			_progressBar.visible = false;
			_progressBar.includeInLayout = false;
			
			_progressBar.mode = ProgressBarMode.EVENT;
			_progressBar.source = this;
			
			_progressBar.label = "%3%%";
			_progressBar.labelPlacement = "center";
			
			this.addChild( _progressBar );
		}
		
		/**
		 * Set the dimensions of the progress bar
		 */
		protected function evaluateProgressSize():void
		{
			if( _progressBar == null )
				return;
				
			_progressBar.x 		= this.width * ( ( 1 - ( progressPercentWidth / 100 ) ) * 0.5 );
			_progressBar.y 		= ( this.height * 0.5 ) - ( progressHeight * 0.5 );
			_progressBar.width 	= this.width * ( progressPercentWidth / 100 );
			_progressBar.height = progressHeight
		}
		
		/**
		 * Show the progress bar
		 */
		protected function showProgress():void
		{
			// resets the progress bar before it is shown
			this.dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, 100 ) );
			
			_progressBar.visible = true;
		}
		
		/**
		 * Hide the progress bar
		 */
		protected function hideProgress():void
		{
			_progressBar.visible = false;
		}
		

//---------------------------------------------------------------------
// Event handlers
//---------------------------------------------------------------------
		
		private function progressCreated( event:FlexEvent ):void
		{
			evaluateProgressSize();
		}
		
		private function resizeHandler( event:ResizeEvent ):void
		{
			evaluateProgressSize();
		}
		
		private function openHandler( event:Event ):void
		{
			showProgress();
		}

		private function completeHandler( event:Event ):void
		{
			hideProgress();
		}
		
		private function ioErrorHandler( event:IOErrorEvent ):void
		{
			hideProgress();
		}

		private function securityErrorHandler( event:SecurityError ):void
		{
			hideProgress()
		}
		
	}
}