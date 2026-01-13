#!/usr/bin/env python3
"""
Demo script to show the resource monitor functionality without interactive UI
This is useful for testing and demonstrations in non-TTY environments
"""

from resource_monitor import ResourceMonitor
import time

def demo():
    """Run a simple demo of the resource monitor"""
    monitor = ResourceMonitor()
    
    print("=" * 80)
    print("Linux Resource Monitor - Demo Mode")
    print("=" * 80)
    print()
    
    # Get process information
    processes = monitor.get_process_info()
    
    # Show process mode
    print(">>> PROCESS MONITORING MODE (Top 10 by CPU) <<<")
    print("-" * 80)
    print(f"{'PID':<8} {'USER':<12} {'CPU%':<8} {'MEM%':<8} {'COMMAND':<40}")
    print("-" * 80)
    
    processes.sort(key=lambda x: x['cpu'], reverse=True)
    for proc in processes[:10]:
        command = proc['command'][:38] if len(proc['command']) > 38 else proc['command']
        print(f"{proc['pid']:<8} {proc['user']:<12} {proc['cpu']:<8.1f} {proc['memory']:<8.1f} {command:<40}")
    
    print()
    print("=" * 80)
    print()
    
    # Show user aggregation mode
    print(">>> USER AGGREGATION MODE (Sorted by Total CPU) <<<")
    print("-" * 80)
    print(f"{'USER':<16} {'PROCESSES':<12} {'TOTAL CPU%':<12} {'TOTAL MEM%':<12}")
    print("-" * 80)
    
    user_stats = monitor.get_user_aggregated_info(processes)
    user_stats.sort(key=lambda x: x['cpu'], reverse=True)
    
    for user_stat in user_stats[:15]:  # Show top 15 users
        print(f"{user_stat['user']:<16} {user_stat['processes']:<12} {user_stat['cpu']:<12.1f} {user_stat['memory']:<12.1f}")
    
    print()
    print("=" * 80)
    print("Demo completed! Run './resource_monitor.py' for interactive mode.")
    print("=" * 80)

if __name__ == "__main__":
    demo()
