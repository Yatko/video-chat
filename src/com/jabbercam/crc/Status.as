package com.jabbercam.crc
{
	public class Status
	{
		public static const INVALID : int = 0;
		public static const READY : int = 1;
		public static const CALLING : int = 2;
		public static const CONNECTED : int = 4 | READY;
		public static const STARTED : int = 8 | CONNECTED;
		public static const CONNECTED_TO_PEER : int = 16 | STARTED;
	}
}