interface Element {
    /**
     * Schedule this element to render after imba.commit()
     */
    schedule(): this;
    unschedule(): this;
}

interface ImbaElement implements Element {
}

interface Imba {
    setInterval(handler: TimerHandler, timeout?: number, ...arguments: any[]): number;
    setTimeout(handler: TimerHandler, timeout?: number, ...arguments: any[]): number;
    clearInterval(handle?: number): void;
    clearTimeout(handle?: number): void;
    commit(): Promise<this>;

    createIndexedFragment(...arguments: any[]): DocumentFragment;
    createKeyedFragment(...arguments: any[]): DocumentFragment;
    createLiveFragment(...arguments: any[]): DocumentFragment;
}

declare const imba: Imba