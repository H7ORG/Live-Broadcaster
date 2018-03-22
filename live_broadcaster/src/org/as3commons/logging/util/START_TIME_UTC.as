/**
 * Created by IntelliJ IDEA.
 * User: mini
 * Date: 12/01/05
 * Time: 10:31
 * To change this template use File | Settings | File Templates.
 */
package org.as3commons.logging.util {
    import flash.utils.getTimer;

    public const START_TIME_UTC: Number =  new Date().getTime() - getTimer() + (new Date().getTimezoneOffset()*1000);
}
