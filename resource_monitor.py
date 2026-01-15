#!/usr/bin/env python3
"""
Linux Resource Monitor - A top-like tool for monitoring system resources
Shows top 10 processes by resource usage with real-time updates
Supports switching between process view and user aggregation view
"""

import psutil
import curses
import time
from collections import defaultdict
from datetime import datetime


class ResourceMonitor:
    def __init__(self, refresh_interval=3.0):
        self.mode = 'process'  # 'process' or 'user'
        self.sort_by = 'cpu'   # 'cpu' or 'memory'
        self.refresh_interval = refresh_interval  # Configurable refresh interval in seconds
        
    def get_process_info(self):
        """Get information about all running processes"""
        processes = []
        for proc in psutil.process_iter(['pid', 'name', 'username', 'cpu_percent', 'memory_percent', 'cmdline']):
            try:
                pinfo = proc.info
                # Get the full command line or process name
                cmdline = ' '.join(pinfo['cmdline']) if pinfo['cmdline'] else pinfo['name']
                processes.append({
                    'pid': pinfo['pid'],
                    'user': pinfo['username'],
                    'cpu': pinfo['cpu_percent'],
                    'memory': pinfo['memory_percent'],
                    'command': cmdline
                })
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        return processes
    
    def get_user_aggregated_info(self, processes):
        """Aggregate resource usage by user"""
        user_stats = defaultdict(lambda: {'cpu': 0.0, 'memory': 0.0, 'processes': 0})
        
        for proc in processes:
            user = proc['user']
            user_stats[user]['cpu'] += proc['cpu']
            user_stats[user]['memory'] += proc['memory']
            user_stats[user]['processes'] += 1
        
        # Convert to list format
        user_list = []
        for user, stats in user_stats.items():
            user_list.append({
                'user': user,
                'cpu': stats['cpu'],
                'memory': stats['memory'],
                'processes': stats['processes']
            })
        
        return user_list
    
    def get_system_stats(self):
        """Collect all system statistics at once"""
        cpu_percent = psutil.cpu_percent(interval=0)
        mem = psutil.virtual_memory()
        uptime = time.time() - psutil.boot_time()
        uptime_str = time.strftime("%H:%M:%S", time.gmtime(uptime))
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        return {
            'cpu_percent': cpu_percent,
            'mem_percent': mem.percent,
            'mem_used_gb': mem.used/1024/1024/1024,
            'mem_total_gb': mem.total/1024/1024/1024,
            'uptime_str': uptime_str,
            'current_time': current_time
        }
    
    def draw_header(self, stdscr, height, width, system_stats):
        """Draw the header with system information"""
        # Draw header
        try:
            stdscr.addstr(0, 0, f"Linux Resource Monitor - {system_stats['current_time']}".ljust(width-1))
            stdscr.addstr(1, 0, f"Uptime: {system_stats['uptime_str']} | CPU: {system_stats['cpu_percent']:5.1f}% | Memory: {system_stats['mem_percent']:5.1f}% ({system_stats['mem_used_gb']:.1f}GB/{system_stats['mem_total_gb']:.1f}GB)")
            stdscr.addstr(2, 0, "-" * (width-1))
            
            # Mode and controls
            mode_text = f"Mode: {'PROCESS' if self.mode == 'process' else 'USER'} | Sort: {self.sort_by.upper()} | Refresh: {self.refresh_interval}s"
            controls = "[p]Process [c]CPU [q]Quit"
            stdscr.addstr(3, 0, mode_text)
            stdscr.addstr(4, 0, controls)
            stdscr.addstr(5, 0, "-" * (width-1))
        except curses.error:
            pass
    
    def draw_process_view(self, stdscr, processes, start_row, height, width):
        """Draw the process monitoring view"""
        # Sort processes
        if self.sort_by == 'cpu':
            processes.sort(key=lambda x: x['cpu'], reverse=True)
        else:
            processes.sort(key=lambda x: x['memory'], reverse=True)
        
        # Header for process view
        try:
            header = f"{'PID':<8} {'USER':<12} {'CPU%':<8} {'MEM%':<8} {'COMMAND':<50}"
            stdscr.addstr(start_row, 0, header[:width-1], curses.A_BOLD)
            stdscr.addstr(start_row + 1, 0, "-" * (width-1))
        except curses.error:
            pass
        
        # Display top 10 processes
        row = start_row + 2
        for i, proc in enumerate(processes[:10]):
            if row >= height - 1:
                break
            
            try:
                # Truncate command if too long
                command = proc['command'][:48] if len(proc['command']) > 48 else proc['command']
                line = f"{proc['pid']:<8} {proc['user']:<12} {proc['cpu']:<8.1f} {proc['memory']:<8.1f} {command:<50}"
                stdscr.addstr(row, 0, line[:width-1])
                row += 1
            except curses.error:
                pass
    
    def draw_user_view(self, stdscr, user_stats, start_row, height, width):
        """Draw the user aggregated view"""
        # Sort by CPU or memory
        if self.sort_by == 'cpu':
            user_stats.sort(key=lambda x: x['cpu'], reverse=True)
        else:
            user_stats.sort(key=lambda x: x['memory'], reverse=True)
        
        # Header for user view
        try:
            header = f"{'USER':<16} {'PROCESSES':<12} {'TOTAL CPU%':<12} {'TOTAL MEM%':<12}"
            stdscr.addstr(start_row, 0, header[:width-1], curses.A_BOLD)
            stdscr.addstr(start_row + 1, 0, "-" * (width-1))
        except curses.error:
            pass
        
        # Display user statistics
        row = start_row + 2
        for user_stat in user_stats:
            if row >= height - 1:
                break
            
            try:
                line = f"{user_stat['user']:<16} {user_stat['processes']:<12} {user_stat['cpu']:<12.1f} {user_stat['memory']:<12.1f}"
                stdscr.addstr(row, 0, line[:width-1])
                row += 1
            except curses.error:
                pass
    
    def run(self, stdscr):
        """Main loop for the monitor"""
        # Setup curses
        try:
            curses.curs_set(0)  # Hide cursor
        except curses.error:
            pass  # Some terminals don't support cursor visibility changes
        stdscr.nodelay(1)   # Non-blocking input
        stdscr.timeout(100)  # 100ms timeout for responsive input
        
        # Initialize CPU percent (first call returns 0)
        psutil.cpu_percent(interval=0.1)
        
        last_refresh_time = 0
        
        while True:
            current_time = time.time()
            
            # Check if it's time to refresh the display
            if current_time - last_refresh_time >= self.refresh_interval:
                # Collect all data at once for instant update
                system_stats = self.get_system_stats()
                processes = self.get_process_info()
                
                # Get terminal size
                height, width = stdscr.getmaxyx()
                
                # Clear screen
                stdscr.clear()
                
                # Draw header
                self.draw_header(stdscr, height, width, system_stats)
                
                # Draw appropriate view
                start_row = 6
                if self.mode == 'process':
                    self.draw_process_view(stdscr, processes, start_row, height, width)
                else:  # user mode
                    user_stats = self.get_user_aggregated_info(processes)
                    self.draw_user_view(stdscr, user_stats, start_row, height, width)
                
                # Refresh screen
                stdscr.refresh()
                
                last_refresh_time = current_time
            
            # Handle input (non-blocking, responsive)
            try:
                key = stdscr.getch()
                if key == ord('q') or key == ord('Q'):
                    break
                elif key == ord('p') or key == ord('P'):
                    # Toggle between process and user mode
                    self.mode = 'user' if self.mode == 'process' else 'process'
                    last_refresh_time = 0  # Force immediate refresh
                elif key == ord('c') or key == ord('C'):
                    # Toggle between cpu and memory sort
                    self.sort_by = 'memory' if self.sort_by == 'cpu' else 'cpu'
                    last_refresh_time = 0  # Force immediate refresh
            except curses.error:
                pass  # No input available
            
            # Small sleep to reduce CPU usage
            time.sleep(0.05)


def main():
    """Entry point for the resource monitor"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Linux Resource Monitor - A top-like system monitoring tool')
    parser.add_argument('-r', '--refresh', type=float, default=3.0, 
                        help='Refresh interval in seconds (default: 3.0)')
    args = parser.parse_args()
    
    # Validate refresh interval
    if args.refresh < 0.5:
        print("Error: Refresh interval must be at least 0.5 seconds")
        return 1
    
    monitor = ResourceMonitor(refresh_interval=args.refresh)
    try:
        curses.wrapper(monitor.run)
    except KeyboardInterrupt:
        print("\nExiting...")
    
    return 0


if __name__ == "__main__":
    main()
